<?php

function GetRegisterValue($register) {
	$cmd = "sudo sh /root/cmv_reg.sh ".$register;

	return shell_exec($cmd);
} 

function SetRegisterValue($register, $value) {
	$cmd = "sudo sh /root/cmv_reg.sh ".$register." ".$value;

	return shell_exec($cmd);
} 

function GetRegisters() {
	//$cmd = "sudo bash /root/registers.sh";
	$cmd = "sudo /bin/sh /root/cmv_reg_read_all.sh";
	$return = shell_exec($cmd);
	$registers = explode("\n", $return);
	for ($i = 0; $i < 128; $i++) {
		$registers[$i] = substr($registers[$i], 6);
	}
	return $registers;
} 

// Calculate exposure time in milliseconds
function  CalcExposureTime($time, $reg82, $reg85, $bits, $lvds) {
	$fot_overlap = (34 * (hexdec($reg82) & 0x00FF)) + 1;  
	return (($time - 1) * (hexdec($reg85) + 1) + $fot_overlap) * ($bits/$lvds) * 1e3;
}

// Calculate exposure register values
function  CalcExposureRegisters($time, $reg82, $reg85, $bits, $lvds) {
	$fot_overlap = (34 * (hexdec($reg82) & 0x00FF)) + 1; 
	$a = ((($time / (($bits/$lvds) * 1e3)) - $fot_overlap) / (hexdec($reg85) + 1)) + 1;

	$temp[1] = round($a/65536); 
	$temp[0] = round($a - $a/65536);
	return $temp;
}

function ExtractBits($input, $position, $length = 1) {
	$temp = decbin(hexdec($input));
	$start = strlen($temp) - $position - $length;
	return bindec(substr($temp, $start, $length));
}

function GetExposureTime() {
	$registers = GetRegisters();
	return CalcExposureTime(hexdec($registers[72])*65536+hexdec($registers[71]), $registers[82], $registers[85], 12, 250000000);
}

function SetExposureTime($time) {
	$registers = GetRegisters();
	$regs = CalcExposureRegisters($time, $registers[82], $registers[85], 12, 250000000);
	SetRegisterValue(71, $regs[0]);
	SetRegisterValue(72, $regs[1]);
}

function SetImageFlipping($option) {
	if (($option == 0) || ($option == 1) || ($option == 2) || ($option == 3)) { 
		SetRegisterValue(69, $option);
	}
}
function SetGain($option) {
	if ($option == 0){
		SetRegisterValue(115, $option);
		return 0;
	}
	if ($option == 1){
		SetRegisterValue(115, $option);
		return 1;
	}
	if ($option == 3){
		SetRegisterValue(115, $option);
		return 3;
	}
	if ($option == 7){
		SetRegisterValue(115, $option);
		return 7;
	}
	return -1;
}

function GetBlackSunProtection() {
	$registers = GetRegisters();
	return ExtractBits($registers[102], 0, 7);
}

function SetBlackSunProtection($option) {
	if ($option < 0) 
		$option = 0;
	if ($option > 127) 
		$option = 127;	
	SetRegisterValue(102, $option + 8192);
	return $option;
}

function SetGamma($gamma) {
	//$cmd = "busybox su -c \"cd ../libraries/; ./gamma_conf.sh ".$gamma."\"";
	$cmd = "sudo bash /root/gamma_conf.sh ".$gamma;
	return shell_exec($cmd);
}

function SetYCbCrGamma($gamma) {
	//$cmd = "busybox su -c \"cd ../libraries/; ./ycbcr_gamma_conf.sh ".$gamma."\"";
//workaround until ycrcb mode is implemented
	$cmd = "sudo bash /root/gamma_conf.sh ".$gamma;
	return shell_exec($cmd);
}

function SetMat4($parameter) {
	//$cmd = "busybox su -c \"cd ../libraries/; ./mat4_conf.sh ".$parameter."\"";

	return shell_exec($cmd);
}

function SetLinLut($parameter) {
	//$cmd = "busybox su -c \"cd ../libraries/; ./linear_rgb_conf.sh ".$parameter."\"";

	return shell_exec($cmd);
}

/*
function GetLUTs() {
	$cmd = "busybox su -c \". ../libraries/lut.sh\"";
	$return = shell_exec($cmd);
	$registers = explode("\n", $return);
	for ($i = 0; $i < 256; $i++) {
		$registers[$i] = hexdec(substr($registers[$i], 6));
	}
	return $registers;
} */

function GetLUTs($channel) {

	switch ($channel) {
		case 0: $chan = "0x80300000";
		break;
		
		case 1: $chan = "0x80304000";
		break;
		
		case 2: $chan = "0x80308000";
		break;
		
		case 3: $chan = "0x8030C000";
		break;
	}
	
	//$cmd = "busybox su -c \"cd ../libraries/ ; ./lut_conf3 -d -B ".$chan."\"";
	$cmd = "sudo /root/lut_conf3 -d -B ".$chan;
	$return = shell_exec($cmd);
	$LUT = explode("\n", $return);
	for ($i = 0; $i < 256; $i++) {
		//echo $LUT[$i*16]." | ";
		$temp = preg_match('/\d{1,10} (\d{1,10})/', $LUT[$i*16], $test);
		$ret[$i] = $test[1];
	}
	return $ret;
} 
?>
