<?php
include("../libraries/func.php");

function GetHistogram() {
	//$cmd = "busybox su -c \"../libraries/cmv_hist3 -d 3 -b 256\"";
	$cmd = "sudo /root/cmv_hist3 -d 3 -b 256";
	$return = shell_exec($cmd);
	$registers = explode("\n", $return);
	return $registers;
} 
$histogram = GetHistogram();
// This reads all the register values into one big array via a shell script
//$registers = GetRegisters();
$registers[69] = 2;

/*
$registers[69] == 0
No image flipping
Bayer Order:
R  G1
G2 B
Channel Order:
1  2
3  4


$registers[69] == 1
Image flipping in X
Bayer Order:
G1 R 
B  G2
Channel Order:
2  1
4  3


$registers[69] == 2
Image flipping in Y
Bayer Order:
G2 B 
R G1
Channel Order:
3  4
1  2


$registers[69] == 3
image flipping in X and Y
Bayer Order:
B G2 
G1 R 
Channel Order:
4  3
2  1

*/
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta http-equiv="refresh" content="0.5" >
	<title>apertus° AXIOM Beta Histogram</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link href="../libraries/bootstrap/css/bootstrap.min.css" rel="stylesheet">
	<style type="text/css">
	.container {
		box-sizing: border-box;
		width: 980px;
		height: 600px;
		padding: 20px 15px 15px 15px;
		margin: 15px auto 30px auto;
		border: 1px solid #ddd;
		background: #fff;
		background: linear-gradient(#f6f6f6 0, #fff 50px);
		background: -o-linear-gradient(#f6f6f6 0, #fff 50px);
		background: -ms-linear-gradient(#f6f6f6 0, #fff 50px);
		background: -moz-linear-gradient(#f6f6f6 0, #fff 50px);
		background: -webkit-linear-gradient(#f6f6f6 0, #fff 50px);
		box-shadow: 0 3px 10px rgba(0,0,0,0.15);
		-o-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
		-ms-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
		-moz-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
		-webkit-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
	}

	.placeholder {
		width: 100%;
		height: 100%;
		font-size: 14px;
		line-height: 1.2em;
	}
	</style>
	<!--[if lte IE 8]><script language="javascript" type="text/javascript" src="../libraries/flot/excanvas.min.js"></script><![endif]-->
	<script language="javascript" type="text/javascript" src="../libraries/flot/jquery.js"></script>
	<script language="javascript" type="text/javascript" src="../libraries/flot/jquery.flot.js"></script>
	<script type="text/javascript">

	$(function() {
		var green = [
		<?php
			for ($i = 0; $i < 256; $i++) {
				$channels = preg_replace('/\s+/', ';', $histogram[$i]);
				$channel = explode(";", $channels);
				if ($registers[69] == 0)
					echo "[". $i .", ".@$channel[1]."],";
				if ($registers[69] == 1)
					echo "[". $i .", ".@$channel[2]."],";
				if ($registers[69] == 2)
					echo "[". $i .", ".@$channel[2]."],";
				if ($registers[69] == 3)
					echo "[". $i .", ".@$channel[0]."],";
			}
		?>
			];
			
		var blue = [
		<?php
			for ($i = 0; $i < 256; $i++) {
				$channels = preg_replace('/\s+/', ';', $histogram[$i]);
				$channel = explode(";", $channels);
				if ($registers[69] == 0)
					echo "[". $i.", ".@$channel[0]."],";
				if ($registers[69] == 1)
					echo "[". $i.", ".@$channel[0]."],";
				if ($registers[69] == 2)
					echo "[". $i.", ".@$channel[4]."],";
				if ($registers[69] == 3)
					echo "[". $i.", ".@$channel[2]."],";
				
			}
		?>
			];
			
		var green2 = [
		<?php
			for ($i = 0; $i < 256; $i++) {
				$channels = preg_replace('/\s+/', ';', $histogram[$i]);
				$channel = explode(";", $channels);
				if ($registers[69] == 0)
					echo "[". $i.", ".@$channel[0]."],";
				if ($registers[69] == 1)
					echo "[". $i.", ".@$channel[3]."],";
				if ($registers[69] == 2)
					echo "[". $i.", ".@$channel[3]."],";
				if ($registers[69] == 3)
					echo "[". $i.", ".@$channel[1]."],";
			}
		?>
			];
			
		var red = [
		<?php
			for ($i = 0; $i < 256; $i++) {
				$channels = preg_replace('/\s+/', ';', $histogram[$i]);
				$channel = explode(";", $channels);
				if ($registers[69] == 0)
					echo "[". $i.", ".@$channel[0]."],";
				if ($registers[69] == 1)
					echo "[". $i.", ".@$channel[1]."],";
				if ($registers[69] == 2)
					echo "[". $i.", ".@$channel[1]."],";
				if ($registers[69] == 3)
					echo "[". $i.", ".@$channel[3]."],";
			}
		?>
			];

		$.plot("#placeholder", [ 
			{ label: "green", data: green, color: "#2ED12E" },
			{ label: "blue",  data: blue,  color: "#2E72D1" },
			{ label: "green2",  data: green2,  color: "#58DA58" },
			{ label: "red",  data: red,  color: "#F83737" }	
			] );
	});

	</script>
</head>
<body style="padding:10px;">
    <a class="btn btn-primary" href="/index.php">Back</a> 
    <h1>apertus&deg; AXIOM Beta Histogram</h1>
	<div class="container">
		<div id="placeholder" class="placeholder"></div>
	</div>
</body>
</html>
