# FreePBX 16 Installation on AWS EC2

## 📌 Overview
This project demonstrates the installation and configuration of FreePBX 16 on an AWS EC2 instance for building a cloud-based VoIP system.

## 🏗️ Architecture
- AWS EC2 (Ubuntu)
- Asterisk (Core PBX engine)
- FreePBX GUI
- SIP Endpoints

## ⚙️ Features
- Web-based PBX management
- Extension creation
- Basic call routing
- IVR support

## 🛠️ Prerequisites
Inside AWS account create EC2 instance
- Ubuntu 22.04 LTS
- Instance type: t3.medium (minimum)
- Storage: 10GB minimum
Security group
- TCP 22      (SSH) 
- TCP 80      (HTTP)
- TCP 443     (HTTPS)
- UDP 5060    (SIP)
- UDP 10000-20000 (RTP)

## 🚀 Installation Steps
### - Step 1: Install Asterisk
FreePBX 16 works well with: Asterisk 18 or 20

Bash: 

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

Start Asterisk:

sudo systemctl start asterisk

### - STEP 2: Configure MariaDB

sudo mysql_secure_installation

sudo mysql -u root

This means you're inside the database console.

Create DB:

CREATE DATABASE asterisk;
CREATE USER 'asteriskuser'@'localhost' IDENTIFIED BY 'StrongPassword';
GRANT ALL PRIVILEGES ON asterisk.* TO 'asteriskuser'@'localhost';
FLUSH PRIVILEGES;

Make sure MariaDB is running:

sudo systemctl status mariadb

If not:

sudo systemctl enable mariadb
sudo systemctl start mariadb

### - STEP 3: Download FreePBX

cd /usr/src
sudo wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-16.0-latest.tgz
sudo tar xvf freepbx-16.0-latest.tgz
cd freepbx
sudo ./start_asterisk start
sudo ./install -n

Is it shows any error, then

ps aux | grep asterisk

Also,
Stop Asterisk

sudo systemctl stop asterisk

If that fails:

sudo pkill asterisk

Create Asterisk User & Group

sudo groupadd asterisk
sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk

Fix Permissions

Very important.

sudo chown -R asterisk:asterisk /etc/asterisk
sudo chown -R asterisk:asterisk /var/lib/asterisk
sudo chown -R asterisk:asterisk /var/log/asterisk
sudo chown -R asterisk:asterisk /var/spool/asterisk
sudo chown -R asterisk:asterisk /usr/lib/asterisk
sudo chown -R asterisk:asterisk /var/run/asterisk

Configure Asterisk to Run as asterisk User

Edit:

sudo nano /etc/default/asterisk

Uncomment:

AST_USER="asterisk"
AST_GROUP="asterisk"

Also edit:

sudo nano /etc/asterisk/asterisk.conf

Find these lines:

runuser = root
rungroup = root

Change them to:

runuser = asterisk
rungroup = asterisk

Save & exit.

Start Asterisk Properly

From inside your FreePBX source folder:

cd /usr/src/freepbx
sudo ./start_asterisk start

OR

sudo systemctl start asterisk

### - STEP 6: Check php version and install correct version

Also, check php version

Run:

php -v

If it shows:

PHP 8.1
PHP 8.2
PHP 8.3

Thats the issue.

Correct Solution (Clean & Professional Way)

FreePBX works best with:

PHP 7.4
MariaDB 10.5
Asterisk 18 or 20 LTS
Since you are on Ubuntu (likely 22.04), it installs PHP 8.x by default.

So we must downgrade PHP properly.

Add Ondřej PHP Repo

sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

Install PHP 7.4 + required modules

sudo apt install php7.4 php7.4-cli php7.4-common php7.4-curl \
php7.4-mysql php7.4-xml php7.4-mbstring php7.4-zip \
php7.4-gd php7.4-bcmath php7.4-intl libapache2-mod-php7.4 -y

Disable PHP 8.x

Check what is enabled:

sudo update-alternatives --config php

Select php7.4

Then:

sudo a2dismod php8.1
sudo a2enmod php7.4
sudo systemctl restart apache2

Verify

php -v

It must show:

PHP 7.4.x

Now Run FreePBX Install Again

cd /usr/src/freepbx
sudo ./install -n

### - STEP 7: Fix Permissions and add users

sudo rm /var/www/html/index.html

sudo chown -R asterisk:asterisk /var/www/html
sudo chmod -R 755 /var/www/html

Fix PHP session folder permissions

sudo chown -R www-data:www-data /var/lib/php/sessions
sudo chmod -R 733 /var/lib/php/sessions

Fix FreePBX permissions (VERY IMPORTANT)

sudo chown -R asterisk:asterisk /var/www/html
sudo chown -R asterisk:asterisk /etc/asterisk
sudo chown -R asterisk:asterisk /var/lib/asterisk
sudo chown -R asterisk:asterisk /var/spool/asterisk
sudo chown -R asterisk:asterisk /var/log/asterisk

Then VERY IMPORTANT:

sudo fwconsole chown

If fwconsole doesn’t work:

sudo -u asterisk fwconsole chown

Now allow Apache to read FreePBX config:

sudo chmod 640 /etc/freepbx.conf
sudo chown asterisk:www-data /etc/freepbx.conf

Add Apache user to asterisk group

Very important:

sudo usermod -aG asterisk www-data

Restart Everything

sudo systemctl restart apache2
sudo systemctl restart mariadb
sudo systemctl restart asterisk

Check Apache Config

Make sure this file exists:

sudo nano /etc/apache2/sites-enabled/000-default.conf

Also edit under Virtual Host and save, 

<Directory /var/www/html>
AllowOverride All
</Directory>

Also, 

sudo nano /etc/apache2/apache2.conf

Find this section:

<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

Change:

AllowOverride None

to:

AllowOverride All

So it becomes:

<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

Save and exit.

Make Sure mod_rewrite Is Enabled

FreePBX depends on this.

Run:

sudo a2enmod rewrite
sudo systemctl restart apache2

Add Sudo Rule (VERY IMPORTANT)

sudo nano /etc/sudoers.d/freepbx

Add:

www-data ALL = (asterisk) NOPASSWD: ALL

Then:

sudo chmod 440 /etc/sudoers.d/freepbx

Correct Web Permissions

sudo chown -R asterisk:asterisk /var/www/html
sudo usermod -a -G asterisk www-data
sudo systemctl restart apache2

Start Everything

sudo systemctl start asterisk
sudo -u asterisk fwconsole reload

Add Proper Sudo Permission

Open sudoers safely:

sudo visudo

Add this line at the bottom:

asterisk ALL=(ALL) NOPASSWD: ALL
www-data ALL=(ALL) NOPASSWD: ALL

Save and exit.

Restart Everything Cleanly

sudo fwconsole stop
sudo systemctl restart apache2
sudo fwconsole start
sudo fwconsole reload

Customize FreePBX Chown

FreePBX supports a custom chown config file.

Create this file:

sudo nano /etc/freepbx_chown.conf

Add:

/etc/asterisk 2775
/var/www/html 2775
/var/spool/asterisk 2775

Save and exit.

Now run:

sudo fwconsole chown

Then verify:

ls -ld /etc/asterisk

It should remain as below otherwise, do next step.

drwxrwsr-x  

Edit Apache User

Open:

sudo nano /etc/apache2/envvars

Find:

export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data

Change to:

export APACHE_RUN_USER=asterisk
export APACHE_RUN_GROUP=asterisk

Save.

Restart Apache

sudo systemctl restart apache2

### - Step 8: Check if AMI is Enabled

Exit Asterisk CLI and open:

sudo nano /etc/asterisk/manager.conf

Make sure it contains:

[general]
enabled = yes
port = 5038
bindaddr = 127.0.0.1
displayconnects = yes

If enabled = no → change it to yes.

Save and exit.

### - Step 9: Restart Asterisk

sudo systemctl restart asterisk

Now test again:

telnet 127.0.0.1 5038

It must show connecting…

### - STEP 10: Access GUI

Open browser:

http://EC2-PUBLIC-IP

You should see FreePBX setup page.

If the FreePBX page is only showing minimal options, then it's most likely caused by Ubuntu Minimal

Missing CA certificates.

Fix it:

sudo apt install ca-certificates -y
sudo update-ca-certificates
Then try again:


sudo -u asterisk fwconsole ma refreshsignatures
sudo -u asterisk fwconsole ma installall

## 📞 Create PJSIP Extension

In FreePBX GUI:

Applications → Extensions → Add Extension → Add New PJSIP Extension

Created Extension 1003:

User Extension: 1003
Display Name: Anoop1
Secret: (password)
Transport: UDP (default)
Submit & Apply Config.

Created Extension 1004:

User Extension: 1004
Display Name: Anoop2
Secret: (password)
Transport: UDP (default)
Submit & Apply Config.

Check codecs in SIP settings and match to the extension made.

In FreePBX GUI:

Settings -> Asterisk SIP settings ->  Under codecs check the codecs.


 In this case it has G711(ulaw), G711(alaw) and G729. So make the same with extensions.

Applications → Extensions →Select Extensions -> Advanced ->  Add codecs in the format ulaw&alaw&g729 under Allowed codecs

Submit & Apply Config.

Verify Extensions in Asterisk CLI

Entered CLI:

asterisk -r

Checked endpoints:

pjsip show endpoints

Confirmed:

1003 → Available
1004 → Available
This verified registration was working.

Enable SRTP

We could enable SRTP in FreePBX:

Applications → Extensions → 1003

Set:

Media Encryption = SRTP via in-SDP

Do the same for 1004.

Submit & Apply Config.

Then restart in cli:

fwconsole restart

Test the extensions using microsip

Configure the Microsip extensions and make a test call.

Also enable the logger and see the SIP session for troubleshooting.

pjsip set logger on

Disable the pjsip logger after use

pjsip set logger off



## 👤 Author
Anoop R
https://telco-tech-info.blogspot.com/2026/02/install-freepbx-on-aws-ec2.html
