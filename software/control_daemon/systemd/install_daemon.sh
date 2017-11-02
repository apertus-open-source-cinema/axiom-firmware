echo "--- Check sudo";
if [[ $EUID != 0 ]];
then
    echo "FAILED: Please run as sudo";
    exit;
fi

echo "--- Create folder for daemon";
if [ ! -d "/opt/axiom_daemon" ]; then
    mkdir /opt/axiom_daemon
fi

# Just in case the folder was moved
echo "--- Remove old links of systemd description files";
rm /etc/systemd/system/axiom.service
rm /etc/systemd/system/axiom.socket

echo "--- Copy daemon and systemd description files to /opt";
cp -f axiom.service /opt/axiom_daemon/
cp -f axiom.socket /opt/axiom_daemon/
cp -f axiom_daemon /opt/axiom_daemon/

echo "--- Make new links for systemd description files";
ln -s /opt/axiom_daemon/axiom.service /etc/systemd/system
ln -s /opt/axiom_daemon/axiom.socket /etc/systemd/system

echo "--- Reload daemon info";
systemctl daemon-reload

echo "--- Enable axiom service and show status";
systemctl enable axiom
systemctl start axiom
systemctl status axiom
