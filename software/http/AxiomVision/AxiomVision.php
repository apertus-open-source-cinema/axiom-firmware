<!DOCTYPE html>
<html>
  <head>
    <title>apertus&deg; AxiomVision</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link href="../libraries/bootstrap/css/bootstrap.min.css" rel="stylesheet">
	
	<style>
		body { background-color:black; color:white; padding:10px; }
		.exposuretime-label { font-size:1.5em; display: inline; }
		.exposuretime-value { font-size:2em; display: inline; }
		.gamma-label { font-size:1.5em; display: inline; }
		.gamma-value { font-size:2em; display: inline; }
		.btn-lg { margin:5px; }
    </style>
  </head>
  <body>
  <script src="../libraries/jquery-2.0.3.min.js"></script>
  <p><a class="btn btn-primary" href="/index.php">Back</a></p>
<?php
// This reads all the register values into one big array via a shell script
include("../libraries/func.php");
$registers = GetRegisters();

$EVRow = array(1/6400, 1/3200, 1/1600, 1/800, 1/400, 1/200, 1/100, 1/50, 1/25, 1/12, 1/6, 1/3);
$GammaRow = array(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2);

if (isset($_GET["evindex"]))
	$EVIndex = $_GET["evindex"];
else
	$EVIndex = 5;
	
if (isset($_GET["value"]))
	$value = $_GET["value"];
else
	$value = 0;
	
	
if (isset($_GET["gammaindex"]))
	$GammaIndex = $_GET["gammaindex"];
else
	$GammaIndex = 6;
	
if (isset($_GET["set"])) {
	switch ($_GET["set"]) {
		case "exposure":
			SetExposureTime($value);
			break;
		case "evindex":
			SetExposureTime($EVRow[$EVIndex]*1000);
			break;
		case "gammaindex":
			echo SetGamma($GammaRow[$GammaIndex]);
			break;
		case "gamma":
			echo SetYCbCrGamma($value);
			break;
		case "matrix":
			echo SetLinLut($value);
			break;
	}
}
/*
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "livevideostart")) {
	$cmd = "busybox su -c \". ../libraries/cmv.func ; fil_reg 15 0x01000100\"";
	$value = shell_exec($cmd);
	echo $value;
}
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "livevideostop")) {
	$cmd = "busybox su -c \". ../libraries/cmv.func ; fil_reg 15 0x0\"";
	$value = shell_exec($cmd);
	echo $value;
}
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "hdmihalf")) {
	$cmd = "busybox su -c \". ../libraries/hdmi.func ; pll_reg 22 0x2106\"";
	$value = shell_exec($cmd);
	echo $value;
}
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "hdmifull")) {
	$cmd = "busybox su -c \". ../libraries/hdmi.func ; pll_reg 22 0x2083\"";
	$value = shell_exec($cmd);
	echo $value;
}
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "sawtoothlut")) {
	$cmd = "busybox su -c \"cd ../libraries/; ./lut_conf.sh -M 0x100000 -N 4096\"";
	shell_exec($cmd);
}
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "disableleds")) {
	$cmd = "busybox su -c \". ../libraries/cmv.func ; fil_reg 14 0xFFFF0000\"";
	shell_exec($cmd);
	$cmd = "busybox su -c \". ../libraries/cmv.func ; fil_reg 15 0x01FF01FF\"";
	shell_exec($cmd);
}
*/

$exposure_ns = GetExposureTime();

// Exposure Time
echo "<div class=\"exposuretime-label\">Exposure: </div> ";
echo "<div class=\"exposuretime-value\">".round($exposure_ns, 3)." ms</div><br /><br />";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=19.5\">1/50</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=10\">1/100</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=6.67\">1/150</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=5\">1/200</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=3.34\">1/300</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=2.5\">1/400</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=2\">1/500</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=1.4\">1/700</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=1\">1/1000</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=0.667\">1/1500</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=0.5\">1/2000</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=0.3\">1/3000</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=exposure&value=0.1\">1/10000</a> ";

echo "<br /><br />";

echo "<div class=\"exposuretime-label\">Gamma: </div><br />";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gamma&value=0.4\">0.4</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gamma&value=0.5\">0.5</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gamma&value=0.6\">0.6</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gamma&value=0.7\">0.7</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gamma&value=0.8\">0.8</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gamma&value=0.9\">0.9</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gamma&value=1\">1</a> ";

echo "<br /><br />";

echo "<div class=\"exposuretime-label\">Whitebalance: </div><br />";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=matrix&value=1   0  1   0  1   0\">Unity (1 1 1)</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=matrix&value=1.3 0  1.3 0  1.3 0\">Unity 130% (1.3 1.3 1.3)</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=matrix&value=1.3 0  1.3 0  1.3 0\">Daylight (1.3 1.3 1.3)</a> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=matrix&value=0.75 0 1.3 0 2.4 0\">Tungsten (0.75 1.3 2.4)</a> ";

/*
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=evindex&evindex=". ($EVIndex-1) ."\">-</a> ";
echo "<div class=\"exposuretime-label\">Exposure: </div> ";
echo "<div class=\"exposuretime-value\">".round($exposure_ns, 3)." ms</div> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=evindex&evindex=". ($EVIndex+1) ."\">+</a><br /><br />";
*/
// Gamma
/*
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gammaindex&gammaindex=". ($GammaIndex-1) ."\">-</a> ";
echo "<div class=\"exposuretime-label\">Gamma: </div> ";
echo "<div class=\"exposuretime-value\">".$GammaRow[$GammaIndex]."</div> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gammaindex&gammaindex=". ($GammaIndex+1) ."\">+</a><br /><br />";


// LUTs
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=sawtoothlut\">Sawtooth LUT</a></p>";
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=disableleds\">Disable LEDs</a></p>";

// Misc
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=livevideostart\">Start Live Video</a></p>";
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=livevideostop\">Stop Live Video</a></p>";
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=hdmihalf\">Set HDMI to Half Frequency</a></p>";
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=hdmifull\">Set HDMI to Full Frequency</a></p>";
//echo "<div class=\"gamma-label\">Gamma: </div>";
//echo "<div class=\"gamma-value\">".round($exposure_ns, 3)." ms</div>";*/
?>

    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="../libraries/bootstrap/js/bootstrap.min.js"></script>
  </body>
</html>
