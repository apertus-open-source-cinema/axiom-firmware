<?php

echo "AXIOM Beta: hello world!<br />I am really excited to see you.<br />My Zynq temperature is: ";
echo shell_exec("sudo bash /root/zynq_info.sh")."<br />";


echo "reg 102: ";
echo shell_exec("sudo sh /root/cmv_reg.sh 102;");

?>
