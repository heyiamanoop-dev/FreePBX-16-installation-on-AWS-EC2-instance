#!/bin/bash
sudo sed -i 's/enabled = no/enabled = yes/g' /etc/asterisk/manager.conf
sudo systemctl restart asterisk
