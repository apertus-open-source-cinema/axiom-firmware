<!DOCTYPE html>
<html>
  <head>
    <title>apertus&deg; Axiom Alpha Registers</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link href="../libraries/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  </head>
  <body>
  	<script src="../libraries/jquery-2.0.3.min.js"></script>
	<script>
	function dex2hex(d) {return d.toString(16);}
	
	$( document ).ready(function() {
	<?php
		// generate javascript code with PHP
		// these functions take care of the conversion between hexadecimal and decimal values of each register
		for ($a = 0; $a < 128; $a++) {
			echo '$( "#'.$a.'dec" ).change(function( event ) {
				var decvalue = parseInt($( "#'.$a.'dec" ).val());
				$( "#'.$a.'hex").val("0x" + dex2hex(decvalue));
				$( "#'.$a.'apply").prop("checked", true);
			});
			
			$( "#'.$a.'hex" ).change(function( event ) {
				var decvalue = parseInt($( "#'.$a.'hex" ).val(), 16);
				$( "#'.$a.'dec").val(decvalue);
				$( "#'.$a.'apply").prop("checked", true);
			});';
		}
		
		// Special human readable registers need special javascript functions
		echo '$( "#exptime" ).change(function( event ) {
				$( "#exptimeapply").prop("checked", true);
			});';
		echo '$( "#exptime2" ).change(function( event ) {
				$( "#exptime2apply").prop("checked", true);
			});';
		echo '$( "#exptimekp1" ).change(function( event ) {
				$( "#exptimekp1apply").prop("checked", true);
			});';
		echo '$( "#exptimekp2" ).change(function( event ) {
				$( "#exptimekp2apply").prop("checked", true);
			});';
		echo '$( "#Vtfl2en" ).change(function( event ) {
				$( "#Vtfl2enapply").prop("checked", true);
			});';
		echo '$( "#Vtfl2" ).change(function( event ) {
				$( "#Vtfl2apply").prop("checked", true);
			});';
		echo '$( "#Vtfl3en" ).change(function( event ) {
				$( "#Vtfl3enapply").prop("checked", true);
			});';
		echo '$( "#Vtfl3" ).change(function( event ) {
				$( "#Vtfl3apply").prop("checked", true);
			});';
		echo '$( "#flipping" ).change(function( event ) {
				$( "#flippingapply").prop("checked", true);
			});';
		echo '$( "#blacksun" ).change(function( event ) {
				$( "#blacksunapply").prop("checked", true);
			});';	
		echo '$( "#gain" ).change(function( event ) {
				$( "#gainapply").prop("checked", true);
			});';
	?>
	});
	</script>

<?php
include("../libraries/func.php");

// Load register names from external file
include("registernames.php");

// if no page is selected show all registers by default
if (!isset($_GET['page'])) {
	$page = "all";
} else {
	$page = $_GET['page'];
}

?>

  <div style="padding:0px;">
	  <div style="float:left; padding-right:10px; padding-left:10px; padding-top:10px; width:120px; background-color:#f0f0f9; margin-right: 10px;">
		<p><a class="btn btn-primary" href="/index.php">Back</a></p><br />
		<!-- 
		  The top buttons group registers together by topic.
		  The syntax: simply list all register indexes that should be displayed as GET parameters (key without value)
		-->
		<p><a class="btn <?php if ($page == "all") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=all">All</a></p>
		<p><a class="btn <?php if ($page == "abstractions") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=abstractions&&1&2&3&4&5&6&7&8&9&10&11&12&13&14&15&16&17&18&19&20&21&22&23&24&25&26&27&28&29&30&31&32&33&34&35&36&37&38&39&40&41&42&43&44&45&46&47&48&49&50&51&52&53&54&55&56&57&58&59&60&61&62&63&64&65&66&67&68&69&70&71&72&73&74&75&76&77&78&79&80&81&82&83&84&85&86&87&88&89&90&91&92&93&94&95&96&97&98&99&100&101&102&103&104&105&106&107&108&109&110&111&112&113&114&115&116&117&118&119&120&121&123&124&125&126&127&128">Abstractions</a></p>
		<p><a class="btn <?php if ($page == "window") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=window&1&2&3&4&5&6&7&8&9&10&11&12&13&14&15&16&17&18&19&20&21&22&23&24&25&26&27&28&29&30&31&32&33&34&35&36&37&38&39&40&41&42&43&44&45&46&47&48&49&50&51&52&53&54&55&56&57&58&59&60&61&62&63&64&65">Windowing</a></p> 
		<p><a class="btn <?php if ($page == "image") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=image&68&69">Image</a></p> 
		<p><a class="btn <?php if ($page == "gain") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=gain&87&88&102&115&116&117&118">Gain/Levels</a></p> 
		<p><a class="btn <?php if ($page == "colors") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=colors&68&118">Colors</a></p>
		<p><a class="btn <?php if ($page == "time") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=time&70&71&72">Timing</a></p>
		<p><a class="btn <?php if ($page == "hdr") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=hdr&71&72&73&74&75&76&77&78&79&80&106&118">HDR</a></p>
	  </div>
  <h1 style="margin-top: 0px; padding-top:10px">apertus&deg; Axiom Alpha Registers</h1>

<?php
$registers_to_show = null;
// Which registers to display?
for ($b = 0; $b < 128; $b++) {
	if (isset($_GET[$b])) {
		$registers_to_show[count($registers_to_show)] = $b;
	}
} 

//debug
//print_r($registers_to_show);

// This reads all the register values into one big array via a shell script
$registers = GetRegisters();


//Show an alert notice message at the top when registers are being changed
$alert = "";
if (isset($_POST["form1"])) {
	if ($_POST["form1"] == "Apply") {
		// Apply Register Changes
		for ($j = 0; $j < 128; $j++) {
			if ((isset($_POST[$j."apply"]) && ($_POST[$j."apply"] == "on"))) {
				SetRegisterValue($j, $_POST[$j."dec"]);
				$registers[$j] = strtoupper(dechex($_POST[$j."dec"]));
				$alert .= "Register: ".$j." set to: ".$_POST[$j."dec"]."<br>\n";
			}
		}
		
		//Special Register handling
		if ((isset($_POST["flippingapply"]) && ($_POST["flippingapply"] == "on"))) {
			SetImageFlipping($_POST["flipping"]);
			$alert .= "Register 69 set to: ". $_POST["flipping"] ."<br>\n";
			$registers[69] = $_POST["flipping"];
		}
		if ((isset($_POST["exptimeapply"]) && ($_POST["exptimeapply"] == "on"))) {
			$regs = CalcExposureRegisters($_POST["exptime"], $registers[82], $registers[85], 12, 250000000);
			$alert .= "Exposure Time set to: ".$_POST["exptime"]." ms<br>\n";
			$alert .= "Register 71 set to: ". $regs[0] ."<br>\n";
			$alert .= "Register 72 set to: ". $regs[1] ."<br>\n";
			SetRegisterValue(71, $regs[0]);
			$registers[71] = strtoupper(dechex($regs[0]));
			SetRegisterValue(72, $regs[1]);
			$registers[72] = strtoupper(dechex($regs[1]));
		}
		if ((isset($_POST["exptime2apply"]) && ($_POST["exptime2apply"] == "on"))) {
			$regs = CalcExposureRegisters($_POST["exptime2"], $registers[82], $registers[85], 12, 250000000);
			$alert .= "Exposure Time 2 set to: ".$_POST["exptime2"]." ms<br>\n";
			$alert .= "Register 73 set to: ". $regs[0] ."<br>\n";
			$alert .= "Register 74 set to: ". $regs[1] ."<br>\n";
			SetRegisterValue(73, $regs[0]);
			$registers[73] = strtoupper(dechex($regs[0]));
			SetRegisterValue(74, $regs[1]);
			$registers[74] = strtoupper(dechex($regs[1]));
		}
		if ((isset($_POST["exptimekp1apply"]) && ($_POST["exptimekp1apply"] == "on"))) {
			$regs = CalcExposureRegisters($_POST["exptimekp1"], $registers[82], $registers[85], 12, 250000000);
			$alert .= "Exposure Time Kneepoint 1 set to: ".$_POST["exptimekp1"]." ms<br>\n";
			$alert .= "Register 75 set to: ". $regs[0] ."<br>\n";
			$alert .= "Register 76 set to: ". $regs[1] ."<br>\n";
			SetRegisterValue(75, $regs[0]);
			$registers[75] = strtoupper(dechex($regs[0]));
			SetRegisterValue(76, $regs[1]);
			$registers[76] = strtoupper(dechex($regs[1]));
		}
		if ((isset($_POST["exptimekp2apply"]) && ($_POST["exptimekp2apply"] == "on"))) {
			$regs = CalcExposureRegisters($_POST["exptimekp2"], $registers[82], $registers[85], 12, 250000000);
			$alert .= "Exposure Time Kneepoint 2 set to: ".$_POST["exptimekp2"]." ms<br>\n";
			$alert .= "Register 77 set to: ". $regs[0] ."<br>\n";
			$alert .= "Register 78 set to: ". $regs[1] ."<br>\n";
			SetRegisterValue(77, $regs[0]);
			$registers[77] = strtoupper(dechex($regs[0]));
			SetRegisterValue(78, $regs[1]);
			$registers[78] = strtoupper(dechex($regs[1]));
		}
		if ((isset($_POST["blacksunapply"]) && ($_POST["blacksunapply"] == "on"))) {
			$alert .= "Register 102 set to: ". $_POST["blacksun"]+8192 ."<br>\n";
			$registers[102] = dechex(SetBlackSunProtection($_POST["blacksun"])+8192);
		}	
		if ((isset($_POST["Vtfl3enapply"]) && ($_POST["Vtfl3enapply"] == "on")) || (isset($_POST["Vtfl2enapply"]) && ($_POST["Vtfl2enapply"] == "on")) || (isset($_POST["Vtfl3apply"]) && ($_POST["Vtfl3apply"] == "on")) || (isset($_POST["Vtfl2apply"]) && ($_POST["Vtfl2apply"] == "on"))) {
			$Vtfl3en = $_POST["Vtfl3en"];
			$Vtfl2en = $_POST["Vtfl2en"];
			$Vtfl3 = $_POST["Vtfl3"];
			$Vtfl2 = $_POST["Vtfl2"];
			$tmpreg =  $Vtfl3en*pow(2, 13) + $Vtfl3*pow(2, 7) + $Vtfl2en*pow(2, 6) + $Vtfl2;
			SetRegisterValue(106, $tmpreg);
			$registers[106] = strtoupper(dechex($tmpreg));
		}
		if ((isset($_POST["gainapply"]) && ($_POST["gainapply"] == "on"))) {
			$temp = SetGain($_POST["gain"]);
			if ($temp >= 0 ) {
				$registers[115] = $temp;
				$alert .= "Register 115 set to: ". $temp ."<br>\n";
			}
		}
		
		
		
		// Print Notice Alert
		echo "<div class=\"alert alert-success\">";
		echo $alert;
		echo "</div>"; 
	}
}

// The big register table
echo "<form method=\"POST\"><table class=\"table table-hover table-bordered\"  style=\"width:800px\">";
echo "<tr><th style=\"text-align:center;\" colspan=\"2\">Register</th>
<th style=\"text-align:center;\" colspan=\"2\" align=\"center\">Current Value</th>
<th style=\"text-align:center;\" colspan=\"3\">New Value</th></tr>";
echo "<tr><th style=\"text-align:center;\">Index</th><th style=\"text-align:center;\">Name</th><th style=\"text-align:center;\">dec</th>
<th style=\"text-align:center;\">hex</th><th style=\"text-align:center;\">dec</th><th style=\"text-align:center;\">hex</th><th style=\"text-align:center;\">Apply</th></tr>";
// Show All Registers
if ($page == "all") {
	for ($i = 0; $i < 128; $i++) {
		echo "<tr><td>".$i."</td>
		<td>".$registernames[$i]."</td>
		<td>".hexdec($registers[$i])."</td>
		<td>0x".$registers[$i]."</td>
		<td><input type=\"text\" id=\"".$i."dec\" name=\"".$i."dec\" size=\"6\" value=\"".hexdec($registers[$i])."\"></td>
		<td><input type=\"text\" id=\"".$i."hex\" name=\"".$i."hex\" size=\"6\" value=\"0x".$registers[$i]."\"></td>
		<td><input type=\"checkbox\" id=\"".$i."apply\" name=\"".$i."apply\"></td></tr>";
	}
} else {
	// Show the selected group of registers as defined in the GET Parameters
	foreach ($registers_to_show as $register_to_show) {
		$i = $register_to_show;
		echo "<tr><td>".$i."</td>
		<td>".$registernames[$i]."</td>
		<td>".hexdec($registers[$i])."</td>
		<td>0x".$registers[$i]."</td>
		<td><input type=\"text\" id=\"".$i."dec\" name=\"".$i."dec\" size=\"6\" value=\"".hexdec($registers[$i])."\"></td>
		<td><input type=\"text\" id=\"".$i."hex\" name=\"".$i."hex\" size=\"6\" value=\"0x".$registers[$i]."\"></td>
		<td><input type=\"checkbox\" id=\"".$i."apply\" name=\"".$i."apply\"></td></tr>";
		
		// Special Register Fields to make some more human read-/writeable
		if ($i == 69) {
			echo "<tr class=\"success\"><td></td>
				<td>Image Flipping</td>
				<td></td>
				<td></td>
				<td><select name=\"flipping\" id=\"flipping\">
					<option value=\"0\" ";
					if ($registers[69] == 0)
						echo "selected";
					echo ">No image flipping</option>
					<option value=\"1\"";
					if ($registers[69] == 1)
						echo "selected";
					echo ">Image flipping in X</option>
					<option value=\"2\"";
					if ($registers[69] == 2)
						echo "selected";
					echo ">Image flipping in Y</option>
					<option value=\"3\"";
					if ($registers[69] == 3)
						echo "selected";
					echo ">Image flipping in X and Y</option>
				</select></td>
				<td></td>
				<td><input type=\"checkbox\" id=\"flippingapply\" name=\"flippingapply\"></td></tr>";
		}
		if ($i == 72) {
			$exposure_ns = CalcExposureTime(hexdec($registers[$i])*65536+hexdec($registers[$i-1]), $registers[82], $registers[85], 12, 250000000);
			echo "<tr class=\"success\"><td></td>
				<td>Exposure Time</td>
				<td>".round($exposure_ns, 3)." ms</td>
				<td></td>
				<td><input type=\"text\" id=\"exptime\" name=\"exptime\" size=\"8\" value=\"".round($exposure_ns, 3)."\"> ms</td>
				<td></td>
				<td><input type=\"checkbox\" id=\"exptimeapply\" name=\"exptimeapply\"></td></tr>";
		}
		if ($i == 74) {
			$exposure_ns = CalcExposureTime(hexdec($registers[$i])*65536+hexdec($registers[$i-1]), $registers[82], $registers[85], 12, 250000000);
			echo "<tr class=\"success\"><td></td>
				<td>Exposure Time 2</td>
				<td>".round($exposure_ns, 3)." ms</td>
				<td></td>
				<td><input type=\"text\" id=\"exptime2\" name=\"exptime2\" size=\"8\" value=\"".round($exposure_ns, 3)."\"> ms</td>
				<td></td>
				<td><input type=\"checkbox\" id=\"exptime2apply\" name=\"exptime2apply\"></td></tr>";
		}
		if ($i == 76) {
			$exposurekp1_ns = CalcExposureTime(hexdec($registers[$i])*65536+hexdec($registers[$i-1]), $registers[82], $registers[85], 12, 250000000);
			echo "<tr class=\"success\"><td></td>
				<td>Exposure Time Kneepoint 1</td>
				<td>".round($exposurekp1_ns, 3)." ms</td>
				<td></td>
				<td><input type=\"text\" id=\"exptimekp1\" name=\"exptimekp1\" size=\"8\" value=\"".round($exposurekp1_ns, 3)."\"> ms</td>
				<td></td>
				<td><input type=\"checkbox\" id=\"exptimekp1apply\" name=\"exptimekp1apply\"></td></tr>";
		}
		if ($i == 78) {
			$exposurekp2_ns = CalcExposureTime(hexdec($registers[$i])*65536+hexdec($registers[$i-1]), $registers[82], $registers[85], 12, 250000000);
			echo "<tr class=\"success\"><td></td>
				<td>Exposure Time Kneepoint 2</td>
				<td>".round($exposurekp2_ns, 3)." ms</td>
				<td></td>
				<td><input type=\"text\" id=\"exptimekp2\" name=\"exptimekp2\" size=\"8\" value=\"".round($exposurekp2_ns, 3)."\"> ms</td>
				<td></td>
				<td><input type=\"checkbox\" id=\"exptimekp2apply\" name=\"exptimekp2apply\"></td></tr>";
		}
		if ($i == 102) {
			echo "<tr class=\"success\"><td></td>
				<td>Black Sun Protection</td>
				<td></td>
				<td>Default: 120</td>
				<td><input type=\"text\" id=\"blacksun\" name=\"blacksun\" size=\"8\" value=\"".GetBlackSunProtection()."\"></td>
				<td></td>
				<td><input type=\"checkbox\" id=\"blacksunapply\" name=\"blacksunapply\"></td></tr>";
		}
		if ($i == 106) {
			$hdrvoltage2enabled = ExtractBits($registers[$i], 6);
			$hdrvoltage3enabled = ExtractBits($registers[$i], 13);
			$hdrvoltage2 = ExtractBits($registers[$i], 0, 6);
			$hdrvoltage3 = ExtractBits($registers[$i], 7, 6);
			echo "<tr class=\"success\"><td></td>
				<td>HDR Voltage Level 2 Enabled</td>
				<td>".($hdrvoltage2enabled ? 'enabled' : 'disabled')."</td>
				<td></td>
				<td></td>
				<td><input type=\"text\" id=\"Vtfl2en\" name=\"Vtfl2en\" size=\"8\" value=\"".($hdrvoltage2enabled ? '1' : '0')."\"></td>
				<td><input type=\"checkbox\" id=\"Vtfl2enapply\" name=\"Vtfl2enapply\"></td></tr>
				<tr class=\"success\"><td></td>
				<td>HDR Voltage Level 2 </td>
				<td>".$hdrvoltage2."</td>
				<td></td>
				<td>Range: 0-63</td>
				<td><input type=\"text\" id=\"Vtfl2\" name=\"Vtfl2\" size=\"8\" value=\"".$hdrvoltage2."\"></td>
				<td><input type=\"checkbox\" id=\"Vtfl2apply\" name=\"Vtfl2apply\"></td></tr>
				<tr class=\"success\"><td></td>
				<td>HDR Voltage Level 3 Enabled</td>
				<td>".($hdrvoltage3enabled ? 'enabled' : 'disabled')."</td>
				<td></td>
				<td></td>
				<td><input type=\"text\" id=\"Vtfl3en\" name=\"Vtfl3en\" size=\"8\" value=\"".($hdrvoltage3enabled ? '1' : '0')."\"></td>
				<td><input type=\"checkbox\" id=\"Vtfl3enapply\" name=\"Vtfl3enapply\"></td></tr>
				<tr class=\"success\"><td></td>
				<td>HDR Voltage Level 3 </td>
				<td>".$hdrvoltage3."</td>
				<td></td>
				<td>Range: 0-63</td>
				<td><input type=\"text\" id=\"Vtfl3\" name=\"Vtfl3\" size=\"8\" value=\"".$hdrvoltage3."\"></td>
				<td><input type=\"checkbox\" id=\"Vtfl3apply\" name=\"Vtfl3apply\"></td></tr>";
		}
		if ($i == 115) {
			echo "<tr class=\"success\"><td></td>
				<td>Analog Gain</td>
				<td></td>
				<td></td>
				<td><select name=\"gain\" id=\"gain\">
					<option value=\"0\" ";
					if ($registers[115] == 0)
						echo "selected";
					echo ">1x</option>
					<option value=\"1\"";
					if ($registers[115] == 1)
						echo "selected";
					echo ">2x</option>
					<option value=\"3\"";
					if ($registers[115] == 3)
						echo "selected";
					echo ">3x</option>
					<option value=\"7\"";
					if ($registers[115] == 7)
						echo "selected";
					echo ">4x</option>
				</select></td>
				<td></td>
				<td><input type=\"checkbox\" id=\"gainapply\" name=\"gainapply\"></td></tr>";
		}
	}
}
echo "</table>
<input class=\"btn btn-primary\" type=\"submit\" name=\"form1\" value=\"Apply\"></form>";

?>
   </div>
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://code.jquery.com/jquery.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="../libraries/bootstrap/js/bootstrap.min.js"></script>
  </body>
</html>
