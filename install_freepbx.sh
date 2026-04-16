#!/bin/bash
cd /usr/src
sudo wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-16.0-latest.tgz
sudo tar xvf freepbx-16.0-latest.tgz
cd freepbx
sudo ./start_asterisk start
sudo ./install -n
