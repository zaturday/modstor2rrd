#!/usr/bin/docker build .
#
# VERSION               1.0
# MOD Unisphere 1.1 by Voravit

FROM       alpine:latest
MAINTAINER jirka@dutka.net

ENV HOSTNAME XoruX
ENV VI_IMAGE 1

# create file to see if this is the firstrun when started
RUN touch /firstrun

RUN apk update && apk add \
    bash \
    wget \
    supervisor \
    busybox-suid \
    apache2 \
    bc \
    net-snmp \
    net-snmp-tools \
    rrdtool \
    perl-rrd \
    perl-xml-simple \
    perl-xml-libxml \
    perl-net-ssleay \
    perl-crypt-ssleay \
    perl-net-snmp \
    net-snmp-perl \
    perl-lwp-protocol-https \
    perl-date-format \
    perl-dbd-pg \
    perl-io-tty \
    perl-want \
    # perl-font-ttf \
    net-tools \
    bind-tools \
    libxml2-utils \
    # snmp-mibs-downloader \
    openssh-client \
    openssh-server \
    ttf-dejavu \
    graphviz \
    vim \
    rsyslog \
    tzdata \
    sudo \
    less \
    ed \
    sharutils \
    make \
    tar \
    perl-dev \
    perl-app-cpanminus \
    sqlite \
    perl-dbd-pg \
    perl-dbd-sqlite

# perl-font-ttf fron testing repo (needed for PDF reports)
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community perl-font-ttf
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing sblim-wbemcli

# Install Unisperecli
COPY unispherecli-linux-64-x86-en-us_5.1.0.1376170-2_amd64.deb /root/unispherecli-linux-64-x86-en-us_5.1.0.1376170-2_amd64.deb
RUN chmod +x /root/unispherecli-linux-64-x86-en-us_5.1.0.1376170-2_amd64.deb
RUN dpkg -i /root/unispherecli-linux-64-x86-en-us_5.1.0.1376170-2_amd64.deb

# Cleanup
RUN apt-get clean
RUN rm -f unispherecli-linux-64-x86-en-us_5.1.0.1376170-2_amd64.deb

# install perl PDF API from CPAN
RUN cpanm -l /usr -n PDF::API2

# setup default user
RUN addgroup -S stor2rrd 
RUN adduser -S stor2rrd -G stor2rrd -s /bin/bash
RUN echo 'stor2rrd:xorux4you' | chpasswd
RUN echo '%stor2rrd ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# configure Apache
COPY configs/apache2 /etc/apache2/sites-available
COPY configs/apache2/htpasswd /etc/apache2/conf/

# change apache user to stor2rrd
RUN sed -i 's/^User apache/User stor2rrd/g' /etc/apache2/httpd.conf

# add product installations
ENV STOR_VER_MAJ "7.10"
ENV STOR_VER_MIN "-1"

ENV STOR_VER "$STOR_VER_MAJ$STOR_VER_MIN"

# expose ports for SSH, HTTP, HTTPS
EXPOSE 22 80 443

COPY configs/crontab /var/spool/cron/crontabs/stor2rrd
RUN chmod 640 /var/spool/cron/crontabs/stor2rrd && chown stor2rrd.cron /var/spool/cron/crontabs/stor2rrd

# download tarballs from SF
# ADD http://downloads.sourceforge.net/project/lpar2rrd/lpar2rrd/$LPAR_SF_DIR/lpar2rrd-$LPAR_VER.tar /home/lpar2rrd/
# ADD http://downloads.sourceforge.net/project/stor2rrd/stor2rrd/$STOR_SF_DIR/stor2rrd-$STOR_VER.tar /home/stor2rrd/

# download tarballs from official website
ADD https://stor2rrd.com/download-static/stor2rrd-$STOR_VER.tar /tmp/

# extract tarballs
WORKDIR /tmp
RUN tar xvf stor2rrd-$STOR_VER.tar

COPY supervisord.conf /etc/
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

#RUN mkdir -p /home/lpar2rrd/lpar2rrd/data
#RUN mkdir -p /home/lpar2rrd/lpar2rrd/etc
VOLUME [ "/home/stor2rrd" ]

ENTRYPOINT [ "/startup.sh" ]

