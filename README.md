# cups-google-print

Docker container with CUPS and Google Cloud Print.

At the moment it seems to be working. You need a working 'Service State' file from a google chrome print connector configuration.

## Usage
* Configure mappings:

Type | Container | Client
---|---|---
Path|/config|wherever you want CUPS config stored
Port|631|631
Variable|CUPS_USER_ADMIN|admin (or whatever you want - for logging in to CUPS)
Variable|CUPS_USER_PASSWORD|pass (or whatever you want)

Typical startup command might be:
'''docker run -d --name="cups-google-print" --net="host" --privileged="true" -e TZ="UTC" -e HOST_OS="unRAID" -e "CUPS_USER_ADMIN"="admin" -e "CUPS_USER_PASSWORD"="pass" -e "TCP_PORT_631"="631" -v "/mnt/user/appdata/cups-google-print":"/config":rw -v /dev:/dev -v /etc/avahi/services:/avahi -v /var/run/dbus:/var/run/dbus mnbf9rca/cups-google-print'''

- originally from https://github.com/gfjardim/docker-containers/tree/master/cups
- Removed Chrome and Samsung drivers, and incorporated https://github.com/google/cloud-print-connector/wiki/Install
- Cloned from https://github.com/mnbf9rca/cups-google-print/blob/master/Dockerfile
- Added Epson drivers, added Chrome and removed avahi, Apple Airprint, GCD to get it working on a Synology NAS Docker 
