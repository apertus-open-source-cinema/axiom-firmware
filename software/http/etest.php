<?

include("libraries/func.php");

$reg82 = 4688;
$reg85 = 257;

$bits = 12;
$lvds = 300e6;

for ($time = 100; $time < 10000000; $time *= 3) {
    $reg = CalcExposureRegisters($time, $reg82, $reg85, $bits, $lvds);
    $ns0 = CalcExposureTime($reg[1]*65536 + $reg[0], $reg82, $reg85, $bits, $lvds);
    $new = CalcExposureRegisters($ns0, $reg82, $reg85, $bits, $lvds);

    printf("%04X %04X %04X %04X %04X %04X %10d %10d %d %d\n",
	$reg[0], $reg[1], $new[0], $new[1], $reg82, $reg85, $time, $ns0, $bits, $lvds);
}

?>
