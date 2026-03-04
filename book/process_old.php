<?php

define('CR', "\r\n");

$src = file('guntner.list');

$files = [];

echo count($src).' lines of source '.CR;

$out = '';
$addr = $addr_last = '';

function spaces($count) { return str_repeat(' ', $count); }


foreach ($src as $c => $line) {
	// check for file change
	if (substr($line, 0, 8) == '------- ') {
		$file = trim(explode(' ', $line)[2]);
		if (!array_key_exists($file, $files)) {
			$files[$file] = 0;
		}
		$files[$file]++;
	}
	// process line
	else {
		if ($c > 500 && $c < 555) {
			// process current address pointer
			$words = preg_split('/\s+/', $line);
			$addr = str_pad($words[2], 8, ' ', STR_PAD_LEFT);
			if ($addr != $addr_last && $words[3] != '????') {
				$addr_last = $addr;
				$out .= $addr;
			}
			else $out .= spaces(8);
			// get rest of line
			$out .= spaces(4);
			$ln = trim(substr($line, 16));
			// check for comment
			if (substr($ln, 0, 1) == ';') $out .= spaces(12);
			//$ln = str_replace("\t", str_repeat(' ', 8), $ln);
			$out .= $ln;
			// new line weeeee
			$out .= CR;
		}
	}
}

echo count($files).' files of source '.CR;

echo $out;
