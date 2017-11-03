# Control daemon
Daemon for settings and general control of Axiom Beta

Prequired packages (names are varying between Linux distributions): 
- `cmake`
- `go`
- `libsystemd-dev`
- `lighttpd`

General info:
- REST port: 7070
- Available pages: /settings (PUT/GET)

Build instructions:
- Install required packages
- Clone beta-software repo
- cd into cloned repo
- `cd software/control_daemon`
- `mkdir build`
- `cd build`
- `cmake ..`
- `make -j4`

Setup daemon:
- cd into systemd directory
- copy .socket and .service to `/etc/systemd/system`
- Adjust the path to `axiom_daemon` executable in `.service` (This step will be adjusted later, so daemon is installed to some global place)
- `systemctl enable axiom`
- `systemctl start axiom`
- `systemctl status axiom` to check if the service was started correctly, last line should say "legacy socket initialization" (preliminary log for now, will be improved later)

Setup web GUI:
- Copy TestGUI folder to `/srv/http` (ArchLinux) or `/var/www/html` (Debian-based distributions)
- Modify server address in `main.js` in method sendSettings()
- Temporary: `systemctl start lighttpd`
- Permanent: `systemctl enable lighttpd`  
             `systemctl start lighttpd`
- Check if started correctly with `systemctl status lighttpd`
