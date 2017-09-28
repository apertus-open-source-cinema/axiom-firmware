<?php
include("../libraries/func.php");

// This reads all the register values into one big array via a shell script
$registers = GetRegisters();

$padding = 10;
$height = 512;
$width = 768;

if (isset($_POST["form1"])) {
	if ($_POST["form1"] == "Apply") {
		// Exposure Time 1
		$regs = CalcExposureRegisters($_POST["exptime1"], $registers[82], $registers[85], 12, 250000000);
		SetRegisterValue(71, $regs[0]);
		$registers[71] = strtoupper(dechex($regs[0]));
		SetRegisterValue(72, $regs[1]);
		$registers[72] = strtoupper(dechex($regs[1]));
		
		// Exposure Time 2
		$regs = CalcExposureRegisters($_POST["exptime2"], $registers[82], $registers[85], 12, 250000000);
		SetRegisterValue(75, $regs[0]);
		$registers[75] = strtoupper(dechex($regs[0]));
		SetRegisterValue(76, $regs[1]);
		$registers[76] = strtoupper(dechex($regs[1]));
	
		// Exposure Time 3
		$regs = CalcExposureRegisters($_POST["exptime3"], $registers[82], $registers[85], 12, 250000000);
		SetRegisterValue(77, $regs[0]);
		$registers[77] = strtoupper(dechex($regs[0]));
		SetRegisterValue(78, $regs[1]);
		$registers[78] = strtoupper(dechex($regs[1]));
		
		// Number of Slopes
		SetRegisterValue(79, $_POST["slopes"]);
		$registers[79] = strtoupper(dechex($_POST["slopes"]));
		
		// Vtfl3 & Vtfl2
		
		//range checks
		if ($_POST["VTFL2"] < 0)
			$_POST["VTFL2"] = 0;
		if ($_POST["VTFL2"] > 63)
			$_POST["VTFL2"] = 63;
			
		if ($_POST["VTFL3"] < 0)
			$_POST["VTFL3"] = 0;
		if ($_POST["VTFL3"] > 63)
			$_POST["VTFL3"] = 63;
			
		if ($_POST["VTFL2en"] < 0)
			$_POST["VTFL2en"] = 0;
		if ($_POST["VTFL2en"] > 1)
			$_POST["VTFL2en"] = 1;
		
		if ($_POST["VTFL3en"] < 0)
			$_POST["VTFL3en"] = 0;
		if ($_POST["VTFL3en"] > 1)
			$_POST["VTFL3en"] = 1;
			
		$Vtfl2en = $_POST["VTFL2en"];
		$Vtfl3en = $_POST["VTFL3en"];
		$Vtfl2 = $_POST["VTFL2"];
		$Vtfl3 = $_POST["VTFL3"];

		$tmpreg =  $Vtfl3en*pow(2, 13) + $Vtfl3*pow(2, 7) + $Vtfl2en*pow(2, 6) + $Vtfl2;
		SetRegisterValue(106, $tmpreg);
		$registers[106] = strtoupper(dechex($tmpreg));
	}
}

$exposure1_ns = CalcExposureTime(hexdec($registers[72])*65536+hexdec($registers[71]), $registers[82], $registers[85], 12, 250000000);
$exposure2_ns = CalcExposureTime(hexdec($registers[76])*65536+hexdec($registers[75]), $registers[82], $registers[85], 12, 250000000);
$exposure3_ns = CalcExposureTime(hexdec($registers[78])*65536+hexdec($registers[77]), $registers[82], $registers[85], 12, 250000000);
$PLR_exp2 = $exposure2_ns/$exposure1_ns; //range 0..1 fraction of exposure time 1
$PLR_exp3 = $exposure3_ns/$exposure1_ns; //range 0..1 fraction of exposure time 1
$hdrvoltage2enabled = ExtractBits($registers[106], 6);
$hdrvoltage3enabled = ExtractBits($registers[106], 13);
$PLR_vtfl2 = ExtractBits($registers[106], 0, 6); //range 0..63
$PLR_vtfl3 = ExtractBits($registers[106], 7, 6); //range 0..63
$slopes = hexdec($registers[79]);

// angle of the first part of the response curve in degrees
$alpha = 45;
$alpha= $alpha / 180 * M_PI; // convert to RAD

//Defaults
$width_scale = 0.5;
$ExtendedDR_x = 0;
$kp1_x = 0;
$kp1_y = 0;
$kp2_x = 0;
$kp2_y = 0;
$beta = 1;
$gamma = 1;


if ($slopes == 2) {
	// vertical length of the first part of the response curve
	$height_alpha = 1-($PLR_vtfl2/63); // range 0..1

	// vertical length of the second part of the response curve
	$height_beta = 1-($PLR_vtfl3/63); // range 0..1
	
	// angle of the second part of the response curve
	$beta = atan($exposure2_ns/$exposure1_ns);

	// angle of the third part of the response curve
	$gamma = atan($exposure3_ns/$exposure1_ns);
}
if ($slopes == 3) {
// Notice that the kneepoint numers are swapped on 3 slope mode as per Image Sensor Datasheet page 34

	// vertical length of the first part of the response curve
	$height_alpha = 1-($PLR_vtfl3/63); // range 0..1

	// vertical length of the second part of the response curve
	$height_beta = 1-($PLR_vtfl2/63); // range 0..1
	
	// angle of the second part of the response curve
	$beta = atan($exposure3_ns/$exposure1_ns);

	// angle of the third part of the response curve
	$gamma = atan($exposure2_ns/$exposure1_ns);
}
// vertical length of the third part of the response curve
$height_gamma = 0;



if ($slopes == 2) {
	//Kneepoint 1
	$kp1_x = $height_alpha/tan($alpha);
	$kp1_y = $height_alpha;

	// Extended Dynamic Range Target
	$ExtendedDR_x = $kp1_x+ (1-$height_alpha)/tan($beta);
	$ExtendedDR_y = 1;
}

if ($slopes == 3) {
// Notice that the kneepoint numers are swapped on 3 slope mode as per Image Sensor Datasheet page 34

	//Kneepoint 1
	$kp2_x = $height_alpha/tan($alpha);
	$kp2_y = $height_alpha;

	//Kneepoint 2
	$kp1_x = $kp2_x + ($height_beta - $height_alpha)/tan($beta);
	$kp1_y = $height_beta;

	// Extended Dynamic Range Target
	$ExtendedDR_x = $kp1_x + (1-$height_beta)/tan($gamma);
	$ExtendedDR_y = 1;
}


//Native Dynamic Range
$NativeDR_x = 1/tan($alpha);
$NativeDR_y = 1;

//Native Exposure Time 2 
$Exp02_x = 1/tan($beta);
$Exp02_y = 1;

//Native Exposure Time 3 
$Exp03_x = 1/tan($gamma);
$Exp03_y = 1;

//Rescale the width to show out of bounds values
if (($width*$ExtendedDR_x*$width_scale) > 600)
	$width_scale = 1 / (($width*$ExtendedDR_x)/600);

?>

<!DOCTYPE HTML>
<html>
  <head>
    <style>
      body {
        padding: 10px;
      }
	  .val-input {
		  display: inline-block;
		  width: 60px;
	  }
	  .val-label {
		  display: inline-block;
		  float: left;
		  width: 180px;
	  }
    </style>
    <title>apertus&deg; AXIOM Beta HDR Piecewise Linear Response (PLR) Settings</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link href="../libraries/bootstrap/css/bootstrap.min.css" rel="stylesheet">
	<script src="../libraries/jquery-2.0.3.min.js"></script>
  </head>
  <body>
    <p><a class="btn btn-primary" href="/index.php">Back</a></p>
    <h1 style="margin-top: 0px; padding-top:10px">apertus&deg; AXIOM Beta HDR Piecewise Linear Response (PLR) Settings</h1>
    <div style="float:left; padding-right:10px" id="container1"></div>
	
	<div style="float:left; padding-right:10px" id="settings">
		Settings:</br>
		<?php 
		echo "<form method=\"POST\" id=\"form1\">";
		echo "<p><div class=\"val-label\">Number of Slopes:</div>";
		echo "<input class=\"val-input\" type=\"text\" id=\"slopes\" name=\"slopes\" size=\"6\" value=\"".$slopes."\"></p>"; 
		echo "<p><div class=\"val-label\">Exposure Time 1:</div>";
		echo "<input class=\"val-input\" type=\"text\" id=\"exptime1\" name=\"exptime1\" size=\"6\" value=\"".round($exposure1_ns, 3)."\"> ms</p>"; 
		echo "<p><div class=\"val-label\">Exposure Time Kneepoint 1:</div>";
		echo "<input class=\"val-input\" type=\"text\" id=\"exptime2\" name=\"exptime2\" size=\"6\" value=\"".round($exposure2_ns, 3)."\"> ms</p>"; 
		echo "<p><div class=\"val-label\">Exposure Time Kneepoint 2:</div>";
		echo "<input class=\"val-input\" type=\"text\" id=\"exptime3\" name=\"exptime3\" size=\"6\" value=\"".round($exposure3_ns, 3)."\"> ms</p>"; 
		echo "<p><div class=\"val-label\">Kneepoint 1 enabled:</div>";
		echo "<input class=\"val-input\" type=\"text\" id=\"VTFL2en\" name=\"VTFL2en\" size=\"6\" value=\"".$hdrvoltage2enabled."\"></p>"; 
		echo "<p><div class=\"val-label\">Level Kneepoint 1:</div>";
		echo "<input class=\"val-input\" type=\"text\" id=\"VTFL2\" name=\"VTFL2\" size=\"6\" value=\"".$PLR_vtfl2."\"><br />
			Range 0 - 63 <input type=\"button\" id=\"VTFL2minus5\" value=\"-5\"> <input type=\"button\" id=\"VTFL2minus1\" value=\"-1\"> 
			<input type=\"button\" id=\"VTFL2plus1\" value=\"+1\"> <input type=\"button\" id=\"VTFL2plus5\" value=\"+5\"></p>";
		echo "<p><div class=\"val-label\">Kneepoint 2 enabled:</div>";
		echo "<input class=\"val-input\" type=\"text\" id=\"VTFL3en\" name=\"VTFL3en\" size=\"6\" value=\"".$hdrvoltage3enabled."\"></p>"; 
		echo "<p><div class=\"val-label\">Level Kneepoint 2:</div>";
		echo "<input class=\"val-input\" type=\"text\" id=\"VTFL3\" name=\"VTFL3\" size=\"6\" value=\"".$PLR_vtfl3."\"><br />
			Range 0 - 63 <input type=\"button\" id=\"VTFL3minus5\" value=\"-5\"> <input type=\"button\" id=\"VTFL3minus1\" value=\"-1\"> 
			<input type=\"button\" id=\"VTFL3plus1\" value=\"+1\"> <input type=\"button\" id=\"VTFL3plus5\" value=\"+5\"></p>"; 
		echo "<input class=\"btn btn-primary\" type=\"submit\" id=\"formsubmit\" name=\"form1\" value=\"Apply\"></form>";
		?>
	</div>
	
    <script src="kinetic-v5.0.1.min.js"></script>
    <script defer="defer">
	  // button handlers
	  $( "#VTFL2minus5" ).click(function() {
		$( "#VTFL2" ).val(parseInt($( "#VTFL2" ).val())-5);
		
		if ($( "#VTFL2" ).val() < 0)
			$( "#VTFL2" ).val(0);
			
		$( "#formsubmit" ).click();	
	  });
	   $( "#VTFL2minus1" ).click(function() {
	  	$( "#VTFL2" ).val(parseInt($( "#VTFL2" ).val())-1);
		
		if ($( "#VTFL2" ).val() < 0)
			$( "#VTFL2" ).val(0);
		
		$( "#formsubmit" ).click();	
	  });
	   $( "#VTFL2plus1" ).click(function() {
	  	$( "#VTFL2" ).val(parseInt($( "#VTFL2" ).val())+1);
		
		if ($( "#VTFL2" ).val() > 63)
			$( "#VTFL2" ).val(63);
			
		$( "#formsubmit" ).click();	
	  });
	   $( "#VTFL2plus5" ).click(function() {
	  	$( "#VTFL2" ).val(parseInt($( "#VTFL2" ).val())+5);
		
		if ($( "#VTFL2" ).val() > 63)
			$( "#VTFL2" ).val(63);
		
		$( "#formsubmit" ).click();	
	  });
	  	  
		  
	  $( "#VTFL3minus5" ).click(function() {
		$( "#VTFL3" ).val(parseInt($( "#VTFL3" ).val())-5);
		
		if ($( "#VTFL3" ).val() < 0)
			$( "#VTFL3" ).val(0);
			
		$( "#formsubmit" ).click();	
	  });
	   $( "#VTFL3minus1" ).click(function() {
	  	$( "#VTFL3" ).val(parseInt($( "#VTFL3" ).val())-1);
		
		if ($( "#VTFL3" ).val() < 0)
			$( "#VTFL3" ).val(0);
		
		$( "#formsubmit" ).click();	
	  });
	   $( "#VTFL3plus1" ).click(function() {
	  	$( "#VTFL3" ).val(parseInt($( "#VTFL3" ).val())+1);
		
		if ($( "#VTFL3" ).val() > 63)
			$( "#VTFL3" ).val(63);
			
		$( "#formsubmit" ).click();	
	  });
	   $( "#VTFL3plus5" ).click(function() {
	  	$( "#VTFL3" ).val(parseInt($( "#VTFL3" ).val())+5);
		
		if ($( "#VTFL3" ).val() > 63)
			$( "#VTFL3" ).val(63);
		
		$( "#formsubmit" ).click();	
	  });
	
	
	  // Dynamic range graphic drawing
      var stage = new Kinetic.Stage({
        container: 'container1',
        width: <?php echo $width+2*$padding; ?>,
        height: <?php echo $height+2*$padding; ?>,
      });

      var layer = new Kinetic.Layer();

	  //black background
	  var rect = new Kinetic.Rect({
        x: 0,
        y: 0,
        width: <?php echo $width+2*$padding; ?>,
        height: <?php echo $height+2*$padding; ?>,
        fill: 'black'
      });
      layer.add(rect);
	  
	  //10% background fill
	  var rect2 = new Kinetic.Rect({
        x: <?php echo $padding; ?>,
        y: <?php echo $padding; ?>,
        width: <?php echo $width*0.1; ?>,
        height: <?php echo $height; ?>,
        fill: '#080808'
      });
      layer.add(rect2);
	  
	  //50% background fill
	  var rect3 = new Kinetic.Rect({
        x: <?php echo $padding+$width*0.1; ?>,
        y: <?php echo $padding; ?>,
        width: <?php echo $width*0.4; ?>,
        height: <?php echo $height; ?>,
        fill: '#101010'
      });
      layer.add(rect3);
	  
	  //90% background fill
	  var rect4 = new Kinetic.Rect({
        x: <?php echo $padding+$width*0.5; ?>,
        y: <?php echo $padding; ?>,
        width: <?php echo $width*0.4; ?>,
        height: <?php echo $height; ?>,
        fill: '#181818'
      });
      layer.add(rect4);
	  
	  //100% background fill
	  var rect5 = new Kinetic.Rect({
        x: <?php echo $padding+$width*0.9; ?>,
        y: <?php echo $padding; ?>,
        width: <?php echo $width*0.1; ?>,
        height: <?php echo $height; ?>,
        fill: '#202020'
      });
      layer.add(rect5);
	  
	  //horizontal 0% line
	  var lutaxis1Line = new Kinetic.Line({
		points: [<?php echo $padding; ?>,<?php echo $height+$padding; ?>, <?php echo $width+$padding; ?>, <?php echo $height+$padding; ?>],
        stroke: '#999',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutaxis1Line);
	  
	  //horizontal 100% line
	  var lutaxis3Line = new Kinetic.Line({
		points: [<?php echo $padding; ?>,<?php echo $padding; ?>, <?php echo $width+$padding; ?>, <?php echo $padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutaxis3Line);
	  
	  //vertical 0% line
	  var lutaxis2Line = new Kinetic.Line({
		points: [<?php echo $padding; ?>,<?php echo $height+$padding; ?>, <?php echo $padding; ?>, <?php echo $padding; ?>],
        stroke: '#999',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutaxis2Line);
	  
	  //horizontal 50% line
	  var lutindicatorLine03 = new Kinetic.Line({
		points: [<?php echo $padding; ?>, <?php echo 0.5*$height+$padding; ?>, <?php echo $padding+$width; ?>, <?php echo 0.5*$height+$padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine03);
	  
	  //horizontal 10% line
	  var lutindicatorLine04 = new Kinetic.Line({
		points: [<?php echo $padding; ?>, <?php echo 0.1*$height+$padding; ?>, <?php echo $padding+$width; ?>, <?php echo 0.1*$height+$padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine04);
	  
	  //horizontal 90% line
	  var lutindicatorLine05 = new Kinetic.Line({
		points: [<?php echo $padding; ?>, <?php echo 0.9*$height+$padding; ?>, <?php echo $padding+$width; ?>, <?php echo 0.9*$height+$padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine05);
	  
	  //horizontal 50% label
	  var lutindicatorText04 = new Kinetic.Text({
        x: <?php echo $padding+2; ?>,
        y: <?php echo (($height)*0.5+$padding)+3; ?>,
        text: '50%',
        fontSize: 6,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText04);
	  
	  //horizontal 10% label
	  var lutindicatorText05 = new Kinetic.Text({
        x: <?php echo $padding+2; ?>,
        y: <?php echo (($height)*0.9+$padding)+3; ?>,
        text: '10%',
        fontSize: 6,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText05);
	  
	  //horizontal 90% label
	  var lutindicatorText06 = new Kinetic.Text({
        x: <?php echo $padding+2; ?>,
        y: <?php echo (($height)*0.1+$padding)+3; ?>,
        text: '90%',
        fontSize: 6,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText06);
	  
	  //output label
	  var lutindicatorText07 = new Kinetic.Text({
        x: <?php echo 2; ?>,
        y: <?php echo (($height)*0.5+$padding)+16; ?>,
        text: 'Digital Value',
        fontSize: 8,
        fontFamily: 'Arial',
		rotation: 270,
        fill: '#777'
      });
	  layer.add(lutindicatorText07);
	  
	  //input label
	  var lutindicatorText08 = new Kinetic.Text({
        x: <?php echo (($width)*0.5+$padding)-12; ?>,
        y: <?php echo $height+2*$padding-9; ?>,
        text: 'LIGHT',
        fontSize: 8,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText08);
	  
	  var PLRLine = new Kinetic.Line({
		<?php 
		echo "points: [ ";
		echo $padding.", ".($height+$padding).", ";
		if ($slopes == 1) {
			echo ($width+$padding).", ".($padding)." ],\n";
		}
		if ($slopes == 2) {
			echo (($width*$kp1_x*$width_scale) + $padding).", ".($padding+$height-($kp1_y*$height)).", ";
			echo (($width*$ExtendedDR_x*$width_scale) + $padding).", ".($padding+$height-($height*$ExtendedDR_y))." ],\n";
		}
		if ($slopes == 3) {
			echo (($width*$kp2_x*$width_scale) + $padding).", ".($padding+$height-($height*$kp2_y)).",\n";
			echo (($width*$kp1_x*$width_scale) + $padding).", ".($padding+$height-($kp1_y*$height)).",\n";
			echo (($width*$ExtendedDR_x*$width_scale) + $padding).", ".($padding+$height-($height*$ExtendedDR_y))." ],\n";
		}
		
		?>
        stroke: '#FF0000',
        strokeWidth: 2,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(PLRLine);
	  
	  //Native DR Line
	  var NativeDRLine = new Kinetic.Line({
		<?php 
		echo "points: [ ";
		if ($slopes == 1) {
			echo " ],\n";
		}
		if ($slopes == 2) {
			echo (($width*$kp1_x*$width_scale) + $padding).", ".($padding+$height-($kp1_y*$height)).", ";
			echo (($width*$width_scale*$NativeDR_x)+$padding).", ".($padding)." ],\n";
		}
		if ($slopes == 3) {
			echo (($width*$kp2_x*$width_scale) + $padding).", ".($padding+$height-($kp2_y*$height)).", ";
			echo (($width*$width_scale*$NativeDR_x)+$padding).", ".($padding)." ],\n";
		}
		?>
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
		dash: [6, 6],
        lineJoin: 'round'
      });
      layer.add(NativeDRLine);
	  
	  // Native Exp2 Line
	  var NativeExp2 = new Kinetic.Line({
		<?php 
		echo "points: [ ";
		if ($slopes == 1) {
			echo " ],\n";
		}
		if ($slopes > 1) {
			echo ($padding).", ".($padding+$height).", ";
			echo (($width*$width_scale*$Exp02_x) + $padding).", ".($padding)." ],\n";
		}
		?>
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
		dash: [6, 6],
        lineJoin: 'round'
      });
      <?php
		if ($slopes > 1)
			echo "layer.add(NativeExp2);";
	  ?>
	  
	  // Native Exp3 Line
	  var NativeExp3 = new Kinetic.Line({
		<?php 
		echo "points: [ ";
		if ($slopes == 1) {
			echo " ],\n";
		}
		if ($slopes > 1) {
			echo ($padding).", ".($padding+$height).", ";
			echo (($width*$width_scale*$Exp03_x) + $padding).", ".($padding)." ],\n";
		}
		?>
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
		dash: [6, 6],
        lineJoin: 'round'
      });
      <?php
		if ($slopes > 2)
			echo "layer.add(NativeExp3);";
	  ?>

	  //Native DR Target
	  var NativeDRText01 = new Kinetic.Text({
	  <?php
	    if ($slopes == 1) {
			echo "x: ". (($width) + $padding - 78) .",\n";
			echo "y: 3,\n";
		} else {
			echo "x: ".(($width*$width_scale*$NativeDR_x)+ $padding + 2) .",";
			echo "y: ".($height - ($height*$NativeDR_y) + $padding + 3) .",";
		}
		?>
        text: 'Native Dynamic Range',
        fontSize: 7,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(NativeDRText01);
	  
	  //Extended DR Target
	  var ExtDRText01 = new Kinetic.Text({
        x: 
		<?php 
		
		if ($slopes == 1) {
			$diff_log = 0;
			echo 0;
		}
		if ($slopes == 2) {
			$diff_factor = $ExtendedDR_x / $NativeDR_x;
			$diff_log = log($diff_factor, 2);
			echo ($width*$ExtendedDR_x*$width_scale)+$padding+2; 
		}
		if ($slopes == 3) {
			$diff_factor = $ExtendedDR_x / $NativeDR_x;
			$diff_log = log($diff_factor, 2);
			//$target_x = $kp1_x+(1-$height_beta)/tan($gamma);
			echo ($width*$ExtendedDR_x*$width_scale)+$padding+2; 
		}
		?>,
        y: <?php echo $padding+3; ?>,
        text: 'Extended Dynamic Range:\n+<?php echo round($diff_log, 2); ?> F-Stops',
        fontSize: 10,
        fontFamily: 'Arial',
        fill: '#777'
      });
	   <?php
		if ($slopes > 1)
			echo "layer.add(ExtDRText01);";
	  ?>
	  
	  //kneepoint1
	  var kneepoint1 = new Kinetic.Circle({
	    x: <?php echo (($width*$kp1_x*$width_scale) + $padding); ?>,
        y: <?php echo ($padding+$height-($kp1_y*$height)); ?>,
	    radius: 4,
	    stroke: 'red',
		fill: '#222',
	    strokeWidth: 2
	  });
	  <?php
		if ($slopes > 1)
			echo "layer.add(kneepoint1);";
	  ?>
	  
	  //kneepoint1 label
	  var KP1Label = new Kinetic.Text({
	  <?php
		echo "x: ". (($width*$kp1_x*$width_scale) + $padding + 6) .",\n";
		echo "y: ". ($padding+$height-($kp1_y*$height)-3).",\n";
		?>
        text: 'Kneepoint 1',
        fontSize: 7,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  <?php 
	  if ($slopes > 1) {
		echo "layer.add(KP1Label);";
	  }
	  ?>
	  
	  //kneepoint2
	  var kneepoint2 = new Kinetic.Circle({
	    x: <?php echo (($width*$kp2_x*$width_scale) + $padding); ?>,
        y: <?php echo ($padding+$height-($kp2_y*$height)); ?>,
	    radius: 4,
	    stroke: 'red',
		fill: '#222',
	    strokeWidth: 2
	  });
	  <?php
		if ($slopes > 2)
			echo "layer.add(kneepoint2);";
	  ?>
	  
	  //kneepoint2 label
	  var KP2Label = new Kinetic.Text({
	  <?php
		echo "x: ". (($width*$kp2_x*$width_scale) + $padding + 6) .",\n";
		echo "y: ". ($padding+$height-($kp2_y*$height)-3).",\n";
		?>
        text: 'Kneepoint 2',
        fontSize: 7,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  <?php 
	  if ($slopes > 2) {
		echo "layer.add(KP2Label);";
	  }
	  ?>
	  
      stage.add(layer);
    </script>
  </body>
</html>
