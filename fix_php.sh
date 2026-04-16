#!/bin/bash
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-mysql php7.4-xml php7.4-mbstring php7.4-zip php7.4-gd php7.4-bcmath php7.4-intl libapache2-mod-php7.4 -y
sudo update-alternatives --config php
sudo a2dismod php8.1
sudo a2enmod php7.4
sudo systemctl restart apache2
