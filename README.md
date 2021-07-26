# XoruX STOR2RRD
This is dockerized version of single [XoruX](https://www.xorux.com) application - [STOR2RRD](https://www.stor2rrd.com).

It's based on the latest official [Alpine Linux](https://hub.docker.com/_/alpine) with all necessary dependencies installed.

Quick start:

    docker run -d --name STOR2RRD --restart always -v stor2rrd:/home/stor2rrd zaturday/modstor2rrd

You can set container timezone via env variable TIMEZONE in docker run command:

    docker run -d --name STOR2RRD --restart always -v stor2rrd:/home/stor2rrd -e TIMEZONE="Europe/Prague" zaturday/modstor2rrd

If you want to use this container as a XorMon backend, set XORMON env variable:

    docker run -d --name STOR2RRD --restart always -v stor2rrd:/home/stor2rrd -e XORMON=1 zaturday/modstor2rrd

Application UI can be found on http://\<CONTAINER_IP\>, use admin/admin for login.

You can connect via SSH on port 22 (exposed), username **stor2rrd**, password **xorux4you** - please change it ASAP.
