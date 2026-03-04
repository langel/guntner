<?php

declare(strict_types=1);

const INPUT_FILE = 'guntner.list';
const OUTPUT_DIR = 'chapters';
const COMPILED_OUTPUT_FILE = 'chapters_compiled.txt';
const EOL = "\r\n";
const ADDRESS_TO_CODE_BYTES_SPACES = 2;
const CODE_COLUMN = 14;
const LABEL_COLUMN = 10;
const MAX_CHECK_ISSUES_PRINTED = 80;

/**
 * Extract source file name from DASM FILE marker line.
 */
function parseFileMarker(string $line): ?string
{
    if (!preg_match('/^------- FILE\s+(.+?)(?:\s+LEVEL\s+\d+\s+PASS\s+\d+)?\s*$/', trim($line), $m)) {
        return null;
    }

    return trim($m[1]);
}

/**
 * Append a check issue entry.
 */
function addCheckIssue(array &$issues, string $file, int $lineNo, string $reason, string $content): void
{
    $issues[] = [
        'file' => $file,
        'line' => $lineNo,
        'reason' => $reason,
        'content' => rtrim($content, "\r\n"),
    ];
}

/**
 * Parse a non-marker listing line.
 *
 * Returns [address|null, sourceText] or null if line does not match listing format.
 */
function parseListingLine(string $line): ?array
{
    $line = rtrim($line, "\r\n");

    if ($line === '') {
        return [null, ''];
    }

    if (!preg_match('/^\s*\d+\s+(\S+)(.*)$/', $line, $base)) {
        return null;
    }

    $addressToken = $base[1];
    $tail = $base[2];
    $hasUnknownMarker = false;

    if (preg_match('/^\s+(\?\?\?\?)(.*)$/', $tail, $marked)) {
        $hasUnknownMarker = true;
        $tail = $marked[2];
    }

    $sourceText = ltrim($tail);

    $address = null;
    if (!$hasUnknownMarker) {
        if (preg_match('/^[0-9a-fA-F]{4}$/', $addressToken)) {
            $address = strtolower($addressToken);
        } elseif (preg_match('/^U([0-9a-fA-F]{4})$/', $addressToken, $uMatch)) {
            // DASM uninitialized/zeropage style addresses: keep numeric part for display/rules.
            $address = strtolower($uMatch[1]);
        }
    }

    return [$address, $sourceText];
}

/**
 * Collapse whitespace while preserving a trailing inline comment block.
 */
function normalizeSourceSpacing(string $text): string
{
    $text = trim($text);
    if ($text === '') {
        return '';
    }

    $parts = explode(';', $text, 2);
    $head = preg_replace('/\s+/', ' ', trim($parts[0])) ?? '';

    if (count($parts) === 1) {
        return $head;
    }

    // Preserve exact spacing after ';' from the source listing.
    $comment = ';' . $parts[1];
    if ($head === '') {
        return $comment;
    }

    return $head . ' ' . $comment;
}

/**
 * Detect whether the parsed source text is an include directive.
 */
function isIncludeDirective(string $sourceText): bool
{
    return (bool) preg_match('/^include\b/i', ltrim($sourceText));
}

/**
 * Load label names that are defined with a trailing colon in the original source file.
 */
function loadColonLabelHints(string $sourceBaseName): array
{
    static $cache = [];

    $key = strtolower($sourceBaseName);
    if (array_key_exists($key, $cache)) {
        return $cache[$key];
    }

    $sourcePath = dirname(__DIR__) . DIRECTORY_SEPARATOR . $sourceBaseName;
    if (!is_file($sourcePath)) {
        $cache[$key] = [];
        return $cache[$key];
    }

    $lines = file($sourcePath) ?: [];
    $labels = [];
    foreach ($lines as $line) {
        if (preg_match('/^\s*([A-Za-z_\.@][A-Za-z0-9_\.@]*):(?=\s|$)/', rtrim($line, "\r\n"), $m)) {
            $labels[strtolower($m[1])] = true;
        }
    }

    $cache[$key] = $labels;
    return $cache[$key];
}

/**
 * For zp_vars-like pointer declarations, preserve original whitespace between symbol and byte.
 */
function loadByteDeclarationHints(string $sourceBaseName): array
{
    static $cache = [];

    $key = strtolower($sourceBaseName);
    if (array_key_exists($key, $cache)) {
        return $cache[$key];
    }

    $sourcePath = dirname(__DIR__) . DIRECTORY_SEPARATOR . $sourceBaseName;
    if (!is_file($sourcePath)) {
        $cache[$key] = [];
        return $cache[$key];
    }

    $lines = file($sourcePath) ?: [];
    $hints = [];
    foreach ($lines as $line) {
        $trimmed = rtrim($line, "\r\n");
        if (preg_match('/^\s*([A-Za-z_\.@][A-Za-z0-9_\.@]*)\s+byte\b/i', $trimmed, $m)) {
            $symbol = strtolower($m[1]);
            if (!array_key_exists($symbol, $hints)) {
                $hints[$symbol] = ltrim($trimmed);
            }
        }
    }

    $cache[$key] = $hints;
    return $cache[$key];
}

/**
 * Preserve original spacing for constant declarations (=, EQM, SET).
 */
function loadConstantDeclarationHints(string $sourceBaseName): array
{
    static $cache = [];

    $key = strtolower($sourceBaseName);
    if (array_key_exists($key, $cache)) {
        return $cache[$key];
    }

    $sourcePath = dirname(__DIR__) . DIRECTORY_SEPARATOR . $sourceBaseName;
    if (!is_file($sourcePath)) {
        $cache[$key] = [];
        return $cache[$key];
    }

    $lines = file($sourcePath) ?: [];
    $hints = [];
    foreach ($lines as $line) {
        $trimmed = rtrim($line, "\r\n");
        if (preg_match('/^\s*([A-Za-z_\.@][A-Za-z0-9_\.@]*)\s*(?:=|EQM\b|SET\b)/i', $trimmed, $m)) {
            $symbol = strtolower($m[1]);
            if (!array_key_exists($symbol, $hints)) {
                $hints[$symbol] = ltrim($trimmed);
            }
        }
    }

    $cache[$key] = $hints;
    return $cache[$key];
}

/**
 * Returns symbol name for a constant declaration, or null.
 */
function constantSymbolFromText(string $text): ?string
{
    if (!preg_match('/^\s*([A-Za-z_\.@][A-Za-z0-9_\.@]*)\s*(?:=|EQM\b|SET\b)/i', $text, $m)) {
        return null;
    }

    return strtolower($m[1]);
}

/**
 * Decide if a line begins with a label token.
 */
function isKnownOpOrDirective(string $token): bool
{
    $known = [
        // 6502 opcodes
        'ADC', 'AND', 'ASL', 'BCC', 'BCS', 'BEQ', 'BIT', 'BMI', 'BNE', 'BPL', 'BRK', 'BVC', 'BVS',
        'CLC', 'CLD', 'CLI', 'CLV', 'CMP', 'CPX', 'CPY', 'DEC', 'DEX', 'DEY', 'EOR', 'INC', 'INX',
        'INY', 'JMP', 'JSR', 'LDA', 'LDX', 'LDY', 'LSR', 'NOP', 'ORA', 'PHA', 'PHP', 'PLA', 'PLP',
        'ROL', 'ROR', 'RTI', 'RTS', 'SBC', 'SEC', 'SED', 'SEI', 'STA', 'STX', 'STY', 'TAX', 'TAY',
        'TSX', 'TXA', 'TXS', 'TYA',
        // DASM directives/macros commonly used in this project
        'ORG', 'SEG', 'SEG.U', 'INCLUDE', 'PROCESSOR', 'MAC', 'ENDM', 'SUBROUTINE',
        'BYTE', 'BYTE.B', '.BYTE', '.WORD', 'WORD', '.DB', '.DW', '.DS', '.DSB', '.RES', '.ALIGN',
    ];

    return in_array(strtoupper($token), $known, true);
}

function isLabelToken(string $firstToken, string $rest): bool
{
    if (str_ends_with($firstToken, ':')) {
        return true;
    }

    $dotDirectives = [
        '.BYTE',
        '.WORD',
        '.DB',
        '.DW',
        '.DS',
        '.DSB',
        '.RES',
        '.INCBIN',
        '.ALIGN',
    ];

    // Local labels may start with '.', but common dot-directives should not be label-aligned.
    if (str_starts_with($firstToken, '.') && !in_array(strtoupper($firstToken), $dotDirectives, true)) {
        return true;
    }

    if ($rest === '') {
        // Standalone symbols (non-opcode/non-directive) are labels.
        return !isKnownOpOrDirective($firstToken);
    }

    $restFirst = strtoupper((string) preg_split('/\s+/', $rest)[0]);
    if (in_array($restFirst, ['=', 'EQM', 'SET'], true)) {
        return false;
    }

    return $restFirst === 'SUBROUTINE';
}

/**
 * Format parsed source body so bytes/comment/directives/labels align consistently.
 */
function formatSourceBody(
    string $sourceText,
    array $colonLabelHints,
    string $sourceBaseName,
    array $byteDeclHints,
    array $constantDeclHints
): string
{
    $trimmed = ltrim(str_replace("\t", ' ', $sourceText));
    if ($trimmed === '') {
        return '';
    }

    if ($trimmed[0] === ';') {
        return str_repeat(' ', CODE_COLUMN) . normalizeSourceSpacing($trimmed);
    }

    // Bare local/global labels should always use label alignment.
    if (preg_match('/^[A-Za-z_\.@][A-Za-z0-9_\.@]*:?$/', $trimmed)) {
        $labelToken = $trimmed;
        $labelKey = strtolower(rtrim($labelToken, ':'));
        if (
            !str_ends_with($labelToken, ':')
            && array_key_exists($labelKey, $colonLabelHints)
        ) {
            $labelToken .= ':';
        }

        return str_repeat(' ', LABEL_COLUMN) . $labelToken;
    }

    $tokens = preg_split('/\s+/', $trimmed) ?: [];
    $byteTokens = [];
    $idx = 0;

    while ($idx < count($tokens) && preg_match('/^[0-9a-fA-F]{2}\*?$/', $tokens[$idx])) {
        $byteTokens[] = strtolower($tokens[$idx]);
        $idx++;
    }

    $rawWithoutBytes = implode(' ', array_slice($tokens, $idx));
    $constSymbol = constantSymbolFromText($rawWithoutBytes);
    if ($constSymbol === null) {
        $constSymbol = constantSymbolFromText($trimmed);
    }
    $constHint = ($constSymbol !== null && array_key_exists($constSymbol, $constantDeclHints))
        ? $constantDeclHints[$constSymbol]
        : null;

    if (!empty($byteTokens)) {
        $restRaw = implode(' ', array_slice($tokens, $idx));
        $rest = normalizeSourceSpacing($restRaw);

        if ($constHint !== null) {
            $bytes = implode(' ', $byteTokens);
            $padding = max(1, CODE_COLUMN - strlen($bytes));
            return $bytes . str_repeat(' ', $padding) . $constHint;
        }

        // Normalize data declaration rows: replace listing byte dump with "byte"/"hex".
        if (preg_match('/^(?:\.?byte(?:\.b)?)\b\s*(.*)$/i', $rest, $mByteDecl)) {
            $payload = trim($mByteDecl[1]);
            $line = 'byte';
            if ($payload !== '') {
                $line .= str_repeat(' ', max(1, CODE_COLUMN - strlen($line))) . $payload;
            }
            return $line;
        }

        if (preg_match('/^hex\b\s*(.*)$/i', $rest, $mHexDecl)) {
            $payload = trim($mHexDecl[1]);
            $line = 'hex';
            if ($payload !== '') {
                $line .= str_repeat(' ', max(1, CODE_COLUMN - strlen($line))) . $payload;
            }
            return $line;
        }

        if (preg_match('/^(?:\.?word(?:\.w)?)\b\s*(.*)$/i', $rest, $mWordDecl)) {
            $payload = trim($mWordDecl[1]);
            $line = 'word';
            if ($payload !== '') {
                $line .= str_repeat(' ', max(1, CODE_COLUMN - strlen($line))) . $payload;
            }
            return $line;
        }

        // zp_vars pointer declarations: remove meaningless "00", map "byte.b" -> "byte",
        // and keep original spacing from source file between symbol and byte.
        if (
            strtolower($sourceBaseName) === 'zp_vars.asm'
            && count($byteTokens) === 1
            && strtolower($byteTokens[0]) === '00'
            && preg_match('/^([A-Za-z_\.@][A-Za-z0-9_\.@]*)\s+byte\.b\b(.*)$/i', $rest, $mPtr)
        ) {
            $symbol = $mPtr[1];
            $symbolKey = strtolower($symbol);
            if (array_key_exists($symbolKey, $byteDeclHints)) {
                return str_repeat(' ', LABEL_COLUMN) . $byteDeclHints[$symbolKey];
            }

            $suffix = trim($mPtr[2]);
            $fallback = $symbol . ' byte';
            if ($suffix !== '') {
                $fallback .= ' ' . $suffix;
            }
            return str_repeat(' ', LABEL_COLUMN) . $fallback;
        }

        $bytes = implode(' ', $byteTokens);
        $padding = max(1, CODE_COLUMN - strlen($bytes));
        return $bytes . str_repeat(' ', $padding) . $rest;
    }

    if ($constHint !== null) {
        return str_repeat(' ', CODE_COLUMN) . $constHint;
    }

    $firstToken = $tokens[0];
    $rest = normalizeSourceSpacing(implode(' ', array_slice($tokens, 1)));
    if (isLabelToken($firstToken, $rest)) {
        $labelToken = $firstToken;
        if (
            !str_ends_with($labelToken, ':')
            && array_key_exists(strtolower($labelToken), $colonLabelHints)
        ) {
            $labelToken .= ':';
        }

        $line = str_repeat(' ', LABEL_COLUMN) . $labelToken;
        if ($rest !== '') {
            $padding = max(1, CODE_COLUMN - strlen($line));
            $line .= str_repeat(' ', $padding) . $rest;
        }
        return $line;
    }

    return str_repeat(' ', CODE_COLUMN) . normalizeSourceSpacing($trimmed);
}

/**
 * Turn parsed rows into rendered chapter lines with conditional address display.
 */
function renderRows(
    array $rows,
    array $colonLabelHints,
    string $sourceBaseName,
    array $byteDeclHints,
    array $constantDeclHints
): array
{
    $rendered = [];
    $count = count($rows);

    for ($i = 0; $i < $count; $i++) {
        $currentAddress = $rows[$i]['address'];
        $nextAddress = ($i + 1 < $count) ? $rows[$i + 1]['address'] : null;
        $lineText = formatSourceBody(
            $rows[$i]['text'],
            $colonLabelHints,
            $sourceBaseName,
            $byteDeclHints,
            $constantDeclHints
        );

        $showAddress = false;
        if ($currentAddress !== null && trim($lineText) !== '') {
            if ($i === $count - 1) {
                $showAddress = true;
            } else {
                $showAddress = ($currentAddress !== $nextAddress);
            }
        }

        $prefix = $showAddress ? $currentAddress : '    ';
        $rendered[] = $prefix . str_repeat(' ', ADDRESS_TO_CODE_BYTES_SPACES) . $lineText;
    }

    return $rendered;
}

if (!is_file(INPUT_FILE)) {
    fwrite(STDERR, 'Input file not found: ' . INPUT_FILE . PHP_EOL);
    exit(1);
}

$checkOnly = in_array('--check', $argv, true);

$lines = file(INPUT_FILE);
if ($lines === false) {
    fwrite(STDERR, 'Failed to read input file: ' . INPUT_FILE . PHP_EOL);
    exit(1);
}

$chapters = [];
$chapterOrder = [];
$currentFile = null;
$previousFile = null;
$firstLineAfterFileSwitch = false;
$sourceLinesSeen = 0;
$parsedRows = 0;
$unparsedRows = 0;
$includeLinesRoutedToParent = 0;
$checkIssues = [];

foreach ($lines as $line) {
    $fileMarker = parseFileMarker($line);
    if ($fileMarker !== null) {
        $previousFile = $currentFile;
        $currentFile = $fileMarker;
        $firstLineAfterFileSwitch = true;
        if (!array_key_exists($currentFile, $chapters)) {
            $chapters[$currentFile] = [];
            $chapterOrder[] = $currentFile;
        }
        if ($previousFile !== null && !array_key_exists($previousFile, $chapters)) {
            $chapters[$previousFile] = [];
            $chapterOrder[] = $previousFile;
        }
        continue;
    }

    if ($currentFile === null) {
        continue;
    }

    $sourceLinesSeen++;
    $parsed = parseListingLine($line);
    if ($parsed === null) {
        $unparsedRows++;
        if ($checkOnly) {
            addCheckIssue(
                $checkIssues,
                $currentFile,
                $sourceLinesSeen,
                'Line did not match listing format',
                $line
            );
        }
        continue;
    }

    [$address, $text] = $parsed;

    $targetFile = $currentFile;
    if (
        $firstLineAfterFileSwitch
        && $previousFile !== null
        && isIncludeDirective($text)
    ) {
        $targetFile = $previousFile;
        $includeLinesRoutedToParent++;
    }
    $firstLineAfterFileSwitch = false;

    $chapters[$targetFile][] = [
        'address' => $address,
        'text' => $text,
    ];
    $parsedRows++;
}

if (!is_dir(OUTPUT_DIR) && !mkdir(OUTPUT_DIR, 0777, true) && !is_dir(OUTPUT_DIR)) {
    if (!$checkOnly) {
        fwrite(STDERR, 'Failed to create output directory: ' . OUTPUT_DIR . PHP_EOL);
        exit(1);
    }
}

$writtenFiles = 0;
foreach ($chapters as $sourceFile => $rows) {
    $baseName = basename(str_replace('\\', '/', $sourceFile));
    $outputName = $baseName . '.txt';
    $outputPath = OUTPUT_DIR . DIRECTORY_SEPARATOR . $outputName;

    $colonLabelHints = loadColonLabelHints($baseName);
    $byteDeclHints = loadByteDeclarationHints($baseName);
    $constantDeclHints = loadConstantDeclarationHints($baseName);
    $rendered = renderRows($rows, $colonLabelHints, $baseName, $byteDeclHints, $constantDeclHints);
    $content = implode(EOL, $rendered) . EOL;

    if ($checkOnly) {
        if (!is_file(dirname(__DIR__) . DIRECTORY_SEPARATOR . $baseName)) {
            addCheckIssue($checkIssues, $baseName, 0, 'Original source file not found in parent directory', $baseName);
        }

        foreach ($rendered as $idx => $renderedLine) {
            $lineNo = $idx + 1;
            if (preg_match('/^\s*[0-9a-f]{4}\s*$/i', $renderedLine)) {
                addCheckIssue($checkIssues, $baseName, $lineNo, 'Address-only output line', $renderedLine);
            }
            if (preg_match('/\b(?:byte\.b|\.byte\.b|word\.w|\.word\.w)\b/i', $renderedLine)) {
                addCheckIssue($checkIssues, $baseName, $lineNo, 'Unnormalized data directive token remains', $renderedLine);
            }
            if (strpos($renderedLine, "\t") !== false) {
                addCheckIssue($checkIssues, $baseName, $lineNo, 'Tab character present in output line', $renderedLine);
            }
        }
        continue;
    }

    file_put_contents($outputPath, $content);
    $writtenFiles++;
}

$compiledWritten = false;
if (!$checkOnly) {
    $orderedFiles = array_values(array_unique($chapterOrder));
    $rootFile = 'guntner.dasm';
    $rootIdx = array_search($rootFile, $orderedFiles, true);
    if ($rootIdx !== false) {
        unset($orderedFiles[$rootIdx]);
        array_unshift($orderedFiles, $rootFile);
        $orderedFiles = array_values($orderedFiles);
    } elseif (array_key_exists($rootFile, $chapters)) {
        array_unshift($orderedFiles, $rootFile);
        $orderedFiles = array_values(array_unique($orderedFiles));
    }

    $compiledParts = [];
    foreach ($orderedFiles as $sourceFile) {
        if (!array_key_exists($sourceFile, $chapters)) {
            continue;
        }
        $baseName = basename(str_replace('\\', '/', $sourceFile));
        $header = $baseName;
        $colonLabelHints = loadColonLabelHints($baseName);
        $byteDeclHints = loadByteDeclarationHints($baseName);
        $constantDeclHints = loadConstantDeclarationHints($baseName);
        $rendered = renderRows($chapters[$sourceFile], $colonLabelHints, $baseName, $byteDeclHints, $constantDeclHints);
        $body = implode(EOL, $rendered);
        $compiledParts[] = $header . EOL . $body;
    }

    $compiledContent = implode(EOL . EOL, $compiledParts) . EOL;
    file_put_contents(COMPILED_OUTPUT_FILE, $compiledContent);
    $compiledWritten = true;
}

echo 'Input lines: ' . count($lines) . PHP_EOL;
echo 'Source lines processed: ' . $sourceLinesSeen . PHP_EOL;
echo 'Parsed rows: ' . $parsedRows . PHP_EOL;
echo 'Unparsed rows skipped: ' . $unparsedRows . PHP_EOL;
echo 'Include lines routed to parent: ' . $includeLinesRoutedToParent . PHP_EOL;
echo 'Source files found: ' . count($chapters) . PHP_EOL;
echo 'Chapter files written: ' . $writtenFiles . PHP_EOL;
echo 'Compiled file written: ' . ($compiledWritten ? 'yes' : 'no') . PHP_EOL;
if ($checkOnly) {
    echo 'Check mode: enabled (no files written)' . PHP_EOL;
    echo 'Suspicious lines found: ' . count($checkIssues) . PHP_EOL;
    $printed = min(MAX_CHECK_ISSUES_PRINTED, count($checkIssues));
    for ($i = 0; $i < $printed; $i++) {
        $issue = $checkIssues[$i];
        echo '- [' . $issue['file'] . ':' . $issue['line'] . '] ' . $issue['reason'] . ' :: ' . $issue['content'] . PHP_EOL;
    }
    if (count($checkIssues) > $printed) {
        echo '... and ' . (count($checkIssues) - $printed) . ' more.' . PHP_EOL;
    }
}
