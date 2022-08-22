<?php

$tokens = [];
$token_count = 0;
$line_count = 0;
$files = glob('*asm');
foreach ($files as $file) {
	echo $file."\n";
	$lines = file($file);
	foreach ($lines as $line) {
		$first = substr($line, 0, 1);
		if ($first != " " && $first != "\t" && $first != ";" && $first != "\n") {
			$line = strtok($line, ':');
			$line = strtok($line, ' ');
			$line = strtok($line, "\t");
			$line = trim($line);
			echo $line."\n";
			$tokens[$line] = 0;
			$token_count++;
		}
		$line_count++;
	}
}

echo "\nTOKEN COUNT ".$token_count."\n\n";
echo "now wait there's liek ".count($tokens)." tokens akshually";
echo "\nLINE COUNT ".$line_count."\n\n";

foreach ($files as $file) {
	echo $file."\n";
	$lines = file($file);
	foreach ($lines as $line) {
		foreach($tokens as $token => $count) {
			if (strpos($line, $token) !== FALSE) $tokens[$token]++;
		}
	}
}

$zero_refs = [];
foreach($tokens as $token => $count) {
	echo $token." : ".$count."\n";
	if ($count <= 1) $zero_refs[] = $token;
}

echo "\n\nzero refs found :\n";
echo implode("\n", $zero_refs)."\n\n";



?>
