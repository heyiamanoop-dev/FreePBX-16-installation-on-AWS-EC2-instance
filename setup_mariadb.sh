#!/bin/bash
sudo mysql_secure_installation
sudo mysql -u root <<EOF
CREATE DATABASE asterisk;
CREATE USER 'asteriskuser'@'localhost' IDENTIFIED BY 'StrongPassword';
GRANT ALL PRIVILEGES ON asterisk.* TO 'asteriskuser'@'localhost';
FLUSH PRIVILEGES;
EOF
sudo systemctl enable mariadb
sudo systemctl start mariadb
