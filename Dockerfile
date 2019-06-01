FROM debian:stable-slim
MAINTAINER amacie 

## cloned from gfjardim  / https://github.com/gfjardim/docker-containers / <gfjardim@gmail.com>
## cloned from mnbf9rca  / https://github.com/mnbf9rca/cups-google-print

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Set correct environment variables
ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" DEBIAN_FRONTEND="noninteractive" TERM="xterm"

# Use baseimage-docker's init system
CMD ["/sbin/runit"]




#########################################
##         RUN INSTALL SCRIPT          ##
#########################################
# Configure user nobody to match unRAID's settings
RUN usermod -u 99 nobody \
&& usermod -g 100 nobody \
&& usermod -d /home nobody \
&& chown -R nobody:users /home \
&& rm -rf /etc/service/sshd /etc/service/cron /etc/service/syslog-ng /etc/my_init.d/00_regen_ssh_host_keys.sh

##  <<- removing Samsung printers
## # Repositories
## 
## RUN curl -sSkL -o /tmp/suldr-keyring_1_all.deb http://www.bchemnet.com/suldr/pool/debian/extra/su/suldr-keyring_1_all.deb \
## && dpkg -i /tmp/suldr-keyring_1_all.deb \
## && add-apt-repository "deb http://www.bchemnet.com/suldr/ debian extra" \
## && add-apt-repository ppa:ubuntu-lxc/lxd-stable \
## && sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list

## RUN add-apt-repository ppa:ubuntu-lxc/lxd-stable 
## <-- removing modification of sources host
## \
## && sed -i -e "s#http://[^\s]*archive.ubuntu[^\s]* #mirror://mirrors.ubuntu.com/mirrors.txt #g" /etc/apt/sources.list


# Install Dependencies

RUN apt-get update -qq \
&& apt-get install -qy --force-yes \
 curl \
 cups \
 lsb \
 runit \
&& apt-get -qq -y autoclean \
&& apt-get -qq -y autoremove \
&& apt-get -qq -y clean

RUN curl -sSkL -o /tmp/epson-inkjet-printer-artisan-725-835-series_1.0.0-1lsb3.2_amd64.deb http://download.ebz.epson.net/dsc/op/stable/debian/dists/lsb3.2/main/binary-amd64/epson-inkjet-printer-artisan-725-835-series_1.0.0-1lsb3.2_amd64.deb
RUN curl -sSkL -o /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install -qy /tmp/google-chrome-stable_current_amd64.deb /tmp/epson-inkjet-printer-artisan-725-835-series_1.0.0-1lsb3.2_amd64.deb \
&& apt-get -qq -y autoclean \
&& apt-get -qq -y autoremove \
&& apt-get -qq -y clean

ADD * /tmp/
RUN chmod +x /tmp/*.sh \
&& /tmp/install.sh \
#&& /tmp/make-avahi-autostart.sh \
#&& /tmp/make-gcp-autostart.sh
&& /tmp/chrome.sh

# Create var/run/dbus, Disbale some cups backend that are unusable within a container, Clean install files
RUN mkdir -p /var/run/dbus \
&& mv -f /usr/lib/cups/backend/parallel /usr/lib/cups/backend-available/ || true \
&& mv -f /usr/lib/cups/backend/serial /usr/lib/cups/backend-available/ || true \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* || true 

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
# Export volumes
VOLUME /config /etc/cups/ /var/log/cups /var/spool/cups /var/cache/cups /var/run/dbus
EXPOSE 631

