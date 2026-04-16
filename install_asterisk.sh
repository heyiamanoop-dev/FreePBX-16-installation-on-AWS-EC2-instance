#!/bin/bash
cd /usr/src
sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz
sudo tar xvf asterisk-20-current.tar.gz
cd asterisk-20.*/
sudo contrib/scripts/install_prereq install
sudo ./configure
sudo make
sudo make install
sudo make samples
sudo make config
sudo ldconfig
sudo systemctl start asterisk
