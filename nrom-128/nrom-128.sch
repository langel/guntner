EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "NES NROM-128 Cartridge"
Date "2022-09-24"
Rev "1"
Comp "LoBlast"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L nes:NES_Cart_Edge J1
U 1 1 632EBBEC
P 5850 5750
F 0 "J1" H 6375 9565 50  0000 C CNN
F 1 "NES_Cart_Edge" H 6375 9474 50  0000 C CNN
F 2 "" H 5800 5650 50  0001 C CNN
F 3 "" H 5800 5650 50  0001 C CNN
	1    5850 5750
	1    0    0    -1  
$EndComp
$Comp
L Memory_EPROM:27C512 U1
U 1 1 632EE925
P 2400 2500
F 0 "U1" H 2200 3800 50  0000 C CNN
F 1 "27C512" H 2300 3700 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm" H 2400 2500 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0015.pdf" H 2400 2500 50  0001 C CNN
	1    2400 2500
	1    0    0    -1  
$EndComp
$Comp
L Device:C C1
U 1 1 632EF654
P 9800 5250
F 0 "C1" H 9915 5296 50  0000 L CNN
F 1 "100nF" H 9915 5205 50  0000 L CNN
F 2 "Capacitors_THT:C_Rect_L13.5mm_W4.0mm_P10.00mm_FKS3_FKP3_MKS4" H 9838 5100 50  0001 C CNN
F 3 "~" H 9800 5250 50  0001 C CNN
	1    9800 5250
	1    0    0    -1  
$EndComp
$Comp
L MCU_Microchip_ATtiny:ATtiny13A-PU U3
U 1 1 632F112C
P 9800 1950
F 0 "U3" H 9271 1996 50  0000 R CNN
F 1 "ATtiny13A-PU" H 9271 1905 50  0000 R CNN
F 2 "Package_DIP:DIP-8_W7.62mm" H 9800 1950 50  0001 C CIN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc8126.pdf" H 9800 1950 50  0001 C CNN
	1    9800 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 4950 3200 4950
Entry Wire Line
	3200 4950 3300 4850
Wire Wire Line
	2800 5050 3200 5050
Entry Wire Line
	3200 5050 3300 4950
Wire Wire Line
	2800 5150 3200 5150
Entry Wire Line
	3200 5150 3300 5050
Wire Wire Line
	2800 5250 3200 5250
Entry Wire Line
	3200 5250 3300 5150
Wire Wire Line
	2800 5350 3200 5350
Entry Wire Line
	3200 5350 3300 5250
Wire Wire Line
	2800 5450 3200 5450
Entry Wire Line
	3200 5450 3300 5350
Wire Wire Line
	2800 5550 3200 5550
Entry Wire Line
	3200 5550 3300 5450
Wire Wire Line
	2800 5650 3200 5650
Entry Wire Line
	3200 5650 3300 5550
Text Label 3300 4850 0    50   ~ 0
CPU_DATA_BUS
Text Label 2850 4950 0    50   ~ 0
PRG_D0
Text Label 2850 5050 0    50   ~ 0
PRG_D1
Text Label 2850 5150 0    50   ~ 0
PRG_D2
Text Label 2850 5250 0    50   ~ 0
PRG_D3
Text Label 2850 5350 0    50   ~ 0
PRG_D4
Text Label 2850 5450 0    50   ~ 0
PRG_D5
Text Label 2850 5550 0    50   ~ 0
PRG_D6
Text Label 2850 5650 0    50   ~ 0
PRG_D7
Wire Wire Line
	7000 4500 7400 4500
Entry Wire Line
	7400 4500 7500 4400
Wire Wire Line
	7000 4600 7400 4600
Entry Wire Line
	7400 4600 7500 4500
Wire Wire Line
	7000 4700 7400 4700
Entry Wire Line
	7400 4700 7500 4600
Wire Wire Line
	7000 4800 7400 4800
Entry Wire Line
	7400 4800 7500 4700
Wire Wire Line
	7000 4900 7400 4900
Entry Wire Line
	7400 4900 7500 4800
Wire Wire Line
	7000 5000 7400 5000
Entry Wire Line
	7400 5000 7500 4900
Wire Wire Line
	7000 5100 7400 5100
Entry Wire Line
	7400 5100 7500 5000
Wire Wire Line
	7000 5200 7400 5200
Entry Wire Line
	7400 5200 7500 5100
Text Label 7500 4400 0    50   ~ 0
CPU_DATA_BUS
Text Label 7050 4500 0    50   ~ 0
PRG_D0
Text Label 7050 4600 0    50   ~ 0
PRG_D1
Text Label 7050 4700 0    50   ~ 0
PRG_D2
Text Label 7050 4800 0    50   ~ 0
PRG_D3
Text Label 7050 4900 0    50   ~ 0
PRG_D4
Text Label 7050 5000 0    50   ~ 0
PRG_D5
Text Label 7050 5100 0    50   ~ 0
PRG_D6
Text Label 7050 5200 0    50   ~ 0
PRG_D7
Wire Wire Line
	2800 1600 3200 1600
Entry Wire Line
	3200 1600 3300 1500
Wire Wire Line
	2800 1700 3200 1700
Entry Wire Line
	3200 1700 3300 1600
Wire Wire Line
	2800 1800 3200 1800
Entry Wire Line
	3200 1800 3300 1700
Wire Wire Line
	2800 1900 3200 1900
Entry Wire Line
	3200 1900 3300 1800
Wire Wire Line
	2800 2000 3200 2000
Entry Wire Line
	3200 2000 3300 1900
Wire Wire Line
	2800 2100 3200 2100
Entry Wire Line
	3200 2100 3300 2000
Wire Wire Line
	2800 2200 3200 2200
Entry Wire Line
	3200 2200 3300 2100
Wire Wire Line
	2800 2300 3200 2300
Entry Wire Line
	3200 2300 3300 2200
Text Label 3300 1500 0    50   ~ 0
PPU_DATA_BUS
Text Label 2850 1600 0    50   ~ 0
CHR_D0
Text Label 2850 1700 0    50   ~ 0
CHR_D1
Text Label 2850 1800 0    50   ~ 0
CHR_D2
Text Label 2850 1900 0    50   ~ 0
CHR_D3
Text Label 2850 2000 0    50   ~ 0
CHR_D4
Text Label 2850 2100 0    50   ~ 0
CHR_D5
Text Label 2850 2200 0    50   ~ 0
CHR_D6
Text Label 2850 2300 0    50   ~ 0
CHR_D7
Wire Wire Line
	7000 2500 7500 2500
Wire Wire Line
	7000 2600 7500 2600
Entry Wire Line
	7500 2600 7600 2500
Wire Wire Line
	7000 2700 7500 2700
Entry Wire Line
	7500 2700 7600 2600
Wire Wire Line
	7000 2800 7500 2800
Entry Wire Line
	7500 2800 7600 2700
Text Label 7600 2400 0    50   ~ 0
PPU_DATA_BUS
Text Label 7150 2500 0    50   ~ 0
CHR_D4
Text Label 7150 2600 0    50   ~ 0
CHR_D5
Text Label 7150 2700 0    50   ~ 0
CHR_D6
Text Label 7150 2800 0    50   ~ 0
CHR_D7
Entry Wire Line
	7500 2500 7600 2400
Wire Wire Line
	5100 2800 5750 2800
Entry Wire Line
	5100 2500 5000 2400
Wire Wire Line
	5100 2700 5750 2700
Entry Wire Line
	5100 2600 5000 2500
Wire Wire Line
	5100 2600 5750 2600
Entry Wire Line
	5100 2700 5000 2600
Wire Wire Line
	5100 2500 5750 2500
Entry Wire Line
	5100 2800 5000 2700
Text Label 5000 2100 0    50   ~ 0
PPU_DATA_BUS
Text Label 5200 2800 0    50   ~ 0
CHR_D0
Text Label 5200 2700 0    50   ~ 0
CHR_D1
Text Label 5200 2600 0    50   ~ 0
CHR_D2
Text Label 5200 2500 0    50   ~ 0
CHR_D3
$Comp
L power:GND #PWR0101
U 1 1 633256A7
P 2400 3800
F 0 "#PWR0101" H 2400 3550 50  0001 C CNN
F 1 "GND" H 2405 3627 50  0000 C CNN
F 2 "" H 2400 3800 50  0001 C CNN
F 3 "" H 2400 3800 50  0001 C CNN
	1    2400 3800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 6332588C
P 2400 7150
F 0 "#PWR0102" H 2400 6900 50  0001 C CNN
F 1 "GND" H 2405 6977 50  0000 C CNN
F 2 "" H 2400 7150 50  0001 C CNN
F 3 "" H 2400 7150 50  0001 C CNN
	1    2400 7150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0103
U 1 1 63325C07
P 5550 5850
F 0 "#PWR0103" H 5550 5600 50  0001 C CNN
F 1 "GND" H 5555 5677 50  0000 C CNN
F 2 "" H 5550 5850 50  0001 C CNN
F 3 "" H 5550 5850 50  0001 C CNN
	1    5550 5850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0104
U 1 1 633260AB
P 7200 1750
F 0 "#PWR0104" H 7200 1500 50  0001 C CNN
F 1 "GND" H 7205 1577 50  0000 C CNN
F 2 "" H 7200 1750 50  0001 C CNN
F 3 "" H 7200 1750 50  0001 C CNN
	1    7200 1750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0105
U 1 1 63326CF0
P 9800 2750
F 0 "#PWR0105" H 9800 2500 50  0001 C CNN
F 1 "GND" H 9805 2577 50  0000 C CNN
F 2 "" H 9800 2750 50  0001 C CNN
F 3 "" H 9800 2750 50  0001 C CNN
	1    9800 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	9800 2550 9800 2750
Wire Wire Line
	2400 6950 2400 7150
Wire Wire Line
	2400 3600 2400 3800
Wire Wire Line
	5750 5700 5550 5700
Wire Wire Line
	5550 5700 5550 5850
Wire Wire Line
	7000 2200 7000 1750
Wire Wire Line
	7000 1750 7100 1750
$Comp
L power:VCC #PWR0106
U 1 1 6332BE92
P 5700 1850
F 0 "#PWR0106" H 5700 1700 50  0001 C CNN
F 1 "VCC" H 5715 2023 50  0000 C CNN
F 2 "" H 5700 1850 50  0001 C CNN
F 3 "" H 5700 1850 50  0001 C CNN
	1    5700 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	5750 2200 5700 2200
Wire Wire Line
	5700 2200 5700 1850
$Comp
L power:VCC #PWR0107
U 1 1 6332DB65
P 2800 1200
F 0 "#PWR0107" H 2800 1050 50  0001 C CNN
F 1 "VCC" H 2815 1373 50  0000 C CNN
F 2 "" H 2800 1200 50  0001 C CNN
F 3 "" H 2800 1200 50  0001 C CNN
	1    2800 1200
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0108
U 1 1 6332EBDD
P 2800 4550
F 0 "#PWR0108" H 2800 4400 50  0001 C CNN
F 1 "VCC" H 2815 4723 50  0000 C CNN
F 2 "" H 2800 4550 50  0001 C CNN
F 3 "" H 2800 4550 50  0001 C CNN
	1    2800 4550
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0109
U 1 1 6332FD7B
P 9800 1100
F 0 "#PWR0109" H 9800 950 50  0001 C CNN
F 1 "VCC" H 9815 1273 50  0000 C CNN
F 2 "" H 9800 1100 50  0001 C CNN
F 3 "" H 9800 1100 50  0001 C CNN
	1    9800 1100
	1    0    0    -1  
$EndComp
Wire Wire Line
	9800 1350 9800 1100
Wire Wire Line
	2000 1600 1450 1600
Text Label 1550 1600 0    50   ~ 0
CHR_A0
Entry Wire Line
	1350 1500 1450 1600
Wire Wire Line
	2000 1700 1450 1700
Text Label 1550 1700 0    50   ~ 0
CHR_A1
Entry Wire Line
	1350 1600 1450 1700
Wire Wire Line
	2000 1800 1450 1800
Text Label 1550 1800 0    50   ~ 0
CHR_A2
Entry Wire Line
	1350 1700 1450 1800
Wire Wire Line
	2000 1900 1450 1900
Text Label 1550 1900 0    50   ~ 0
CHR_A3
Entry Wire Line
	1350 1800 1450 1900
Wire Wire Line
	2000 2000 1450 2000
Text Label 1550 2000 0    50   ~ 0
CHR_A4
Entry Wire Line
	1350 1900 1450 2000
Wire Wire Line
	2000 2100 1450 2100
Text Label 1550 2100 0    50   ~ 0
CHR_A5
Entry Wire Line
	1350 2000 1450 2100
Wire Wire Line
	2000 2200 1450 2200
Text Label 1550 2200 0    50   ~ 0
CHR_A6
Entry Wire Line
	1350 2100 1450 2200
Wire Wire Line
	2000 2300 1450 2300
Text Label 1550 2300 0    50   ~ 0
CHR_A7
Entry Wire Line
	1350 2200 1450 2300
Wire Wire Line
	2000 2400 1450 2400
Text Label 1550 2400 0    50   ~ 0
CHR_A8
Entry Wire Line
	1350 2300 1450 2400
Wire Wire Line
	2000 2500 1450 2500
Text Label 1550 2500 0    50   ~ 0
CHR_A9
Entry Wire Line
	1350 2400 1450 2500
Wire Wire Line
	2000 2600 1450 2600
Text Label 1550 2600 0    50   ~ 0
CHR_A10
Entry Wire Line
	1350 2500 1450 2600
Wire Wire Line
	2000 2700 1450 2700
Text Label 1550 2700 0    50   ~ 0
CHR_A11
Entry Wire Line
	1350 2600 1450 2700
Wire Wire Line
	2000 2800 1450 2800
Text Label 1550 2800 0    50   ~ 0
CHR_A12
Entry Wire Line
	1350 2700 1450 2800
Text Label 1350 1450 0    50   ~ 0
PPU_ADDRESS_BUS
Wire Wire Line
	2400 1400 2650 1400
Wire Wire Line
	2800 1400 2800 1200
Wire Wire Line
	2800 4750 2400 4750
$Comp
L Memory_EPROM:27C512 U2
U 1 1 632ED9B9
P 2400 5850
F 0 "U2" H 2200 7150 50  0000 C CNN
F 1 "27C512" H 2300 7050 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm" H 2400 5850 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0015.pdf" H 2400 5850 50  0001 C CNN
	1    2400 5850
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 4750 2800 4550
Wire Wire Line
	2000 4950 1450 4950
Text Label 1550 4950 0    50   ~ 0
PRG_A0
Entry Wire Line
	1350 4850 1450 4950
Wire Wire Line
	2000 5050 1450 5050
Text Label 1550 5050 0    50   ~ 0
PRG_A1
Entry Wire Line
	1350 4950 1450 5050
Wire Wire Line
	2000 5150 1450 5150
Text Label 1550 5150 0    50   ~ 0
PRG_A2
Entry Wire Line
	1350 5050 1450 5150
Wire Wire Line
	2000 5250 1450 5250
Text Label 1550 5250 0    50   ~ 0
PRG_A3
Entry Wire Line
	1350 5150 1450 5250
Wire Wire Line
	2000 5350 1450 5350
Text Label 1550 5350 0    50   ~ 0
PRG_A4
Entry Wire Line
	1350 5250 1450 5350
Wire Wire Line
	2000 5450 1450 5450
Text Label 1550 5450 0    50   ~ 0
PRG_A5
Entry Wire Line
	1350 5350 1450 5450
Wire Wire Line
	2000 5550 1450 5550
Text Label 1550 5550 0    50   ~ 0
PRG_A6
Entry Wire Line
	1350 5450 1450 5550
Wire Wire Line
	2000 5650 1450 5650
Text Label 1550 5650 0    50   ~ 0
PRG_A7
Entry Wire Line
	1350 5550 1450 5650
Wire Wire Line
	2000 5750 1450 5750
Text Label 1550 5750 0    50   ~ 0
PRG_A8
Entry Wire Line
	1350 5650 1450 5750
Wire Wire Line
	2000 5850 1450 5850
Text Label 1550 5850 0    50   ~ 0
PRG_A9
Entry Wire Line
	1350 5750 1450 5850
Wire Wire Line
	2000 5950 1450 5950
Text Label 1550 5950 0    50   ~ 0
PRG_A10
Entry Wire Line
	1350 5850 1450 5950
Wire Wire Line
	5750 5600 4950 5600
Text Label 5050 5600 0    50   ~ 0
PRG_A11
Entry Wire Line
	4850 5500 4950 5600
Wire Wire Line
	2000 6150 1450 6150
Text Label 1550 6150 0    50   ~ 0
PRG_A12
Wire Wire Line
	2000 6250 1450 6250
Text Label 1550 6250 0    50   ~ 0
PRG_A13
Entry Wire Line
	1350 6150 1450 6250
Text Label 1350 4800 0    50   ~ 0
CPU_ADDRESS_BUS
Wire Wire Line
	5750 4500 4950 4500
Text Label 5050 4500 0    50   ~ 0
PRG_A0
Entry Wire Line
	4850 4400 4950 4500
Wire Wire Line
	5750 4600 4950 4600
Text Label 5050 4600 0    50   ~ 0
PRG_A1
Entry Wire Line
	4850 4500 4950 4600
Wire Wire Line
	5750 4700 4950 4700
Text Label 5050 4700 0    50   ~ 0
PRG_A2
Entry Wire Line
	4850 4600 4950 4700
Wire Wire Line
	5750 4800 4950 4800
Text Label 5050 4800 0    50   ~ 0
PRG_A3
Entry Wire Line
	4850 4700 4950 4800
Wire Wire Line
	5750 4900 4950 4900
Text Label 5050 4900 0    50   ~ 0
PRG_A4
Entry Wire Line
	4850 4800 4950 4900
Wire Wire Line
	5750 5000 4950 5000
Text Label 5050 5000 0    50   ~ 0
PRG_A5
Entry Wire Line
	4850 4900 4950 5000
Wire Wire Line
	5750 5100 4950 5100
Text Label 5050 5100 0    50   ~ 0
PRG_A6
Entry Wire Line
	4850 5000 4950 5100
Wire Wire Line
	5750 5200 4950 5200
Text Label 5050 5200 0    50   ~ 0
PRG_A7
Entry Wire Line
	4850 5100 4950 5200
Wire Wire Line
	5750 5300 4950 5300
Text Label 5050 5300 0    50   ~ 0
PRG_A8
Entry Wire Line
	4850 5200 4950 5300
Wire Wire Line
	5750 5400 4950 5400
Text Label 5050 5400 0    50   ~ 0
PRG_A9
Entry Wire Line
	4850 5300 4950 5400
Wire Wire Line
	5750 5500 4950 5500
Text Label 5050 5500 0    50   ~ 0
PRG_A10
Entry Wire Line
	4850 5400 4950 5500
Text Label 4850 4350 0    50   ~ 0
CPU_ADDRESS_BUS
Wire Wire Line
	2000 6050 1450 6050
Text Label 1550 6050 0    50   ~ 0
PRG_A11
Entry Wire Line
	1350 5950 1450 6050
Entry Wire Line
	1350 6050 1450 6150
Wire Wire Line
	7800 5500 7000 5500
Text Label 7400 5500 0    50   ~ 0
PRG_A12
Wire Wire Line
	7800 5300 7000 5300
Text Label 7400 5300 0    50   ~ 0
PRG_A14
Wire Wire Line
	7800 5400 7000 5400
Text Label 7400 5400 0    50   ~ 0
PRG_A13
Entry Wire Line
	7800 5300 7900 5200
Entry Wire Line
	7800 5400 7900 5300
Entry Wire Line
	7800 5500 7900 5400
Text Label 7900 5200 0    50   ~ 0
CPU_ADDRESS_BUS
Wire Wire Line
	5750 2900 4250 2900
Text Label 4350 2900 0    50   ~ 0
CHR_A0
Entry Wire Line
	4150 2800 4250 2900
Wire Wire Line
	5750 3000 4250 3000
Text Label 4350 3000 0    50   ~ 0
CHR_A1
Entry Wire Line
	4150 2900 4250 3000
Wire Wire Line
	5750 3100 4250 3100
Text Label 4350 3100 0    50   ~ 0
CHR_A2
Entry Wire Line
	4150 3000 4250 3100
Wire Wire Line
	5750 3200 4250 3200
Text Label 4350 3200 0    50   ~ 0
CHR_A3
Entry Wire Line
	4150 3100 4250 3200
Wire Wire Line
	5750 3300 4250 3300
Text Label 4350 3300 0    50   ~ 0
CHR_A4
Entry Wire Line
	4150 3200 4250 3300
Wire Wire Line
	5750 3400 4250 3400
Text Label 4350 3400 0    50   ~ 0
CHR_A5
Entry Wire Line
	4150 3300 4250 3400
Wire Wire Line
	5750 3500 4250 3500
Text Label 4350 3500 0    50   ~ 0
CHR_A6
Entry Wire Line
	4150 3400 4250 3500
Text Label 4150 2750 0    50   ~ 0
PPU_ADDRESS_BUS
Text Label 7050 2900 0    50   ~ 0
CHR_CE
Text Label 7250 3000 0    50   ~ 0
CHR_A12
Text Label 7250 3100 0    50   ~ 0
CHR_A10
Text Label 7250 3200 0    50   ~ 0
CHR_A11
Text Label 7250 3300 0    50   ~ 0
CHR_A9
Text Label 7250 3400 0    50   ~ 0
CHR_A8
Text Label 7250 3500 0    50   ~ 0
CHR_A7
NoConn ~ 7000 3900
NoConn ~ 7000 4000
NoConn ~ 7000 4100
NoConn ~ 7000 4200
NoConn ~ 7000 4300
NoConn ~ 5750 3800
NoConn ~ 5750 3900
NoConn ~ 5750 4000
NoConn ~ 5750 4100
NoConn ~ 5750 4200
NoConn ~ 5750 4300
NoConn ~ 5750 4400
$Comp
L power:GND #PWR0110
U 1 1 6331B363
P 9800 5500
F 0 "#PWR0110" H 9800 5250 50  0001 C CNN
F 1 "GND" H 9805 5327 50  0000 C CNN
F 2 "" H 9800 5500 50  0001 C CNN
F 3 "" H 9800 5500 50  0001 C CNN
	1    9800 5500
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0111
U 1 1 6331B6C4
P 9800 5000
F 0 "#PWR0111" H 9800 4850 50  0001 C CNN
F 1 "VCC" H 9815 5173 50  0000 C CNN
F 2 "" H 9800 5000 50  0001 C CNN
F 3 "" H 9800 5000 50  0001 C CNN
	1    9800 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	9800 5000 9800 5100
Wire Wire Line
	9800 5400 9800 5500
NoConn ~ 10400 2150
NoConn ~ 10400 2050
Wire Wire Line
	10400 1650 10850 1650
Text Label 10500 1650 0    50   ~ 0
CIC_OUT
Text Label 10500 1750 0    50   ~ 0
CIC_IN
Text Label 10500 1850 0    50   ~ 0
CIC_RST
Text Label 10500 1950 0    50   ~ 0
CIC_CLK
Wire Wire Line
	10400 1750 10850 1750
Wire Wire Line
	10400 1850 10850 1850
Wire Wire Line
	10400 1950 10850 1950
Wire Wire Line
	5300 2300 5750 2300
Text Label 5400 2300 0    50   ~ 0
CIC_OUT
Text Label 5400 2400 0    50   ~ 0
CIC_IN
Text Label 7050 2400 0    50   ~ 0
CIC_RST
Text Label 7050 2300 0    50   ~ 0
CIC_CLK
Wire Wire Line
	5300 2400 5750 2400
Wire Wire Line
	7000 2400 7450 2400
Wire Wire Line
	7000 2300 7450 2300
Wire Wire Line
	7000 3600 7200 3600
Wire Wire Line
	7200 3600 7200 3700
Wire Wire Line
	7200 3700 7000 3700
NoConn ~ 7000 3800
Wire Wire Line
	7000 4400 7400 4400
Text Label 7050 4400 0    50   ~ 0
PRG_OE
Wire Wire Line
	5750 3600 5300 3600
Wire Wire Line
	5750 3700 5300 3700
Text Label 5350 3600 0    50   ~ 0
CHR_A10
Text Label 5350 3700 0    50   ~ 0
CHR_OE
Wire Wire Line
	2000 6750 1550 6750
Text Label 1600 6750 0    50   ~ 0
PRG_OE
Wire Wire Line
	2000 6650 1400 6650
Wire Wire Line
	1400 6650 1400 7150
$Comp
L power:GND #PWR0112
U 1 1 63424171
P 1400 7150
F 0 "#PWR0112" H 1400 6900 50  0001 C CNN
F 1 "GND" H 1405 6977 50  0000 C CNN
F 2 "" H 1400 7150 50  0001 C CNN
F 3 "" H 1400 7150 50  0001 C CNN
	1    1400 7150
	1    0    0    -1  
$EndComp
Text Label 1600 3400 0    50   ~ 0
CHR_OE
$Comp
L power:GND #PWR0113
U 1 1 63424B76
P 1400 3800
F 0 "#PWR0113" H 1400 3550 50  0001 C CNN
F 1 "GND" H 1405 3627 50  0000 C CNN
F 2 "" H 1400 3800 50  0001 C CNN
F 3 "" H 1400 3800 50  0001 C CNN
	1    1400 3800
	1    0    0    -1  
$EndComp
Wire Wire Line
	2000 3400 1550 3400
Wire Wire Line
	2000 3100 1150 3100
Wire Wire Line
	1150 3100 1150 3050
$Comp
L power:VCC #PWR0114
U 1 1 6344577B
P 1150 3050
F 0 "#PWR0114" H 1150 2900 50  0001 C CNN
F 1 "VCC" H 1165 3223 50  0000 C CNN
F 2 "" H 1150 3050 50  0001 C CNN
F 3 "" H 1150 3050 50  0001 C CNN
	1    1150 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	2000 2900 1400 2900
Wire Wire Line
	1400 2900 1400 3000
Wire Wire Line
	2000 3000 1400 3000
Connection ~ 1400 3000
Text Notes 4000 3700 0    50   ~ 0
Pin 22->CHR_A10 HOR SCROLL\nPin 22->CHR_A11 VERT SCROLL
NoConn ~ 7000 5600
NoConn ~ 7000 5700
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 6349A2E4
P 2650 1400
F 0 "#FLG0101" H 2650 1475 50  0001 C CNN
F 1 "PWR_FLAG" H 2650 1573 50  0000 C CNN
F 2 "" H 2650 1400 50  0001 C CNN
F 3 "~" H 2650 1400 50  0001 C CNN
	1    2650 1400
	1    0    0    -1  
$EndComp
Connection ~ 2650 1400
Wire Wire Line
	2650 1400 2800 1400
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 6349B28A
P 7100 1750
F 0 "#FLG0102" H 7100 1825 50  0001 C CNN
F 1 "PWR_FLAG" H 7100 1923 50  0000 C CNN
F 2 "" H 7100 1750 50  0001 C CNN
F 3 "~" H 7100 1750 50  0001 C CNN
	1    7100 1750
	1    0    0    -1  
$EndComp
Connection ~ 7100 1750
Wire Wire Line
	7100 1750 7200 1750
Wire Wire Line
	1400 3000 1400 3800
Wire Wire Line
	2000 3300 1550 3300
Text Label 1600 3300 0    50   ~ 0
CHR_CE
Wire Wire Line
	7650 3500 7000 3500
Wire Wire Line
	7650 3400 7000 3400
Wire Wire Line
	7650 3300 7000 3300
Wire Wire Line
	7650 3200 7000 3200
Wire Wire Line
	7650 3100 7000 3100
Entry Wire Line
	7650 3500 7750 3400
Entry Wire Line
	7650 3400 7750 3300
Entry Wire Line
	7650 3300 7750 3200
Text Label 7750 2800 0    50   ~ 0
PPU_ADDRESS_BUS
Entry Wire Line
	7650 3200 7750 3100
Entry Wire Line
	7650 3100 7750 3000
Wire Wire Line
	7650 3000 7000 3000
Entry Wire Line
	7650 3000 7750 2900
Wire Wire Line
	7000 2900 7450 2900
Text Label 1550 6350 0    50   ~ 0
PRG_A14
Wire Wire Line
	2000 6350 1450 6350
Wire Wire Line
	2000 6450 1150 6450
Wire Wire Line
	1150 6450 1150 6400
Entry Wire Line
	1350 6250 1450 6350
$Comp
L power:VCC #PWR0115
U 1 1 6346ECCC
P 1150 6400
F 0 "#PWR0115" H 1150 6250 50  0001 C CNN
F 1 "VCC" H 1165 6573 50  0000 C CNN
F 2 "" H 1150 6400 50  0001 C CNN
F 3 "" H 1150 6400 50  0001 C CNN
	1    1150 6400
	1    0    0    -1  
$EndComp
Wire Bus Line
	7900 5100 7900 5400
Wire Bus Line
	5000 2000 5000 2700
Wire Bus Line
	7600 2300 7600 2700
Wire Bus Line
	4150 2650 4150 3400
Wire Bus Line
	7750 2700 7750 3400
Wire Bus Line
	3300 1400 3300 2200
Wire Bus Line
	7500 4300 7500 5100
Wire Bus Line
	3300 4750 3300 5550
Wire Bus Line
	1350 1350 1350 2700
Wire Bus Line
	1350 4700 1350 6250
Wire Bus Line
	4850 4250 4850 5500
$EndSCHEMATC
