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
- Install script and systemd description files for daemon will be copied by CMake to the build directory
- After successful build, execute `./install_daemon.sh`
- Required files will be copied to `/opt/axiom_daemon` directory, daemon set up and started
- Finally the status of the daemon will be shown in the terminal

Setup web GUI:
- Copy TestGUI folder to `/srv/http` (ArchLinux) or `/var/www/html` (Debian-based distributions)
- Temporary: `systemctl start lighttpd`
- Permanent: `systemctl enable lighttpd`  
             `systemctl start lighttpd`
- Check if started correctly with `systemctl status lighttpd`
