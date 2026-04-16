#!/bin/bash
sudo groupadd asterisk
sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
sudo chown -R asterisk:asterisk /etc/asterisk
sudo chown -R asterisk:asterisk /var/lib/asterisk
sudo chown -R asterisk:asterisk /var/log/asterisk
sudo chown -R asterisk:asterisk /var/spool/asterisk
sudo chown -R asterisk:asterisk /usr/lib/asterisk
sudo chown -R asterisk:asterisk /var/run/asterisk
sudo chown -R asterisk:asterisk /var/www/html
sudo chmod -R 755 /var/www/html
sudo fwconsole chown
