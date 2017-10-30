mkdir /opt/axiom_daemon
cp -f axiom.service /opt/axiom_daemon/
cp -f axiom.socket /opt/axiom_daemon/
ln -s /opt/axiom_daemon/axiom.service /etc/systemd/system
ln -s /opt/axiom_daemon/axiom.socket /etc/systemd/system
systemctl enable axiom
systemctl start axiom
systemctl status axiom
