#!/bin/bash


#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Add files
cp -f /tmp/*.conf /etc/cups/
cp -f /tmp/etc-pam.d-cups /etc/pam.d/cups
# removed cp -f /tmp/generate_cloudprint_config.py /opt/generate_cloudprint_config.py
# removed chmod +x /opt/generate_cloudprint_config.py
mkdir -p /etc/cups/ssl

# Add services
# Add firstrun.sh to execute during container startup
mkdir -p /etc/my_init.d
cat <<'EOT' >/etc/my_init.d/config.sh
#!/bin/bash

mkdir -p /config/cups /config/spool /config/logs /config/cache /config/cups/ssl /config/cups/ppd /config/cloudprint

# Copy missing config files
cd /etc/cups
for f in *.conf ; do 
  if [ ! -f "/config/cups/${f}" ]; then
    cp ./${f} /config/cups/
  fi
done

EOT
chmod +x /etc/my_init.d/config.sh

# Add cups to runit
mkdir /etc/service/cups
cat <<'EOT' >/etc/service/cups/run
#!/bin/sh
if [ -n "$CUPS_USER_ADMIN" ]; then
  if [ $(grep -ci $CUPS_USER_ADMIN /etc/shadow) -eq 0 ]; then
    useradd $CUPS_USER_ADMIN --system -G root,lpadmin --no-create-home --password $(mkpasswd $CUPS_USER_PASSWORD)
  fi
fi
exec /usr/sbin/cupsd -f -c /config/cups/cupsd.conf
EOT
chmod +x /etc/service/cups/run

# Add chrome to runit
# mkdir /etc/service/chrome
# mv /tmp/chrome.sh /etc/service/chrome/run
