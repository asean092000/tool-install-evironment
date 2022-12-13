#!/bin/bash
# Script author: Bytes Crafter
# Script site: https://www.bytescrafter.net
# Script date: 19-04-2020
# Script ver: 1.0
# Script use to install LEMP stack on Debian 10
#--------------------------------------------------
# Software version:
# 1. OS: 10.3 (Ubuntu) 64 bit
# 2. Nginx: 1.14.2
# 3. MariaDB: 10.3
# 4. Nodejs 18: 18.12.0
#--------------------------------------------------
# List function:
# 1. bc_checkroot: check to make sure script can be run by user root
# 2. bc_update: update all the packages
# 3. bc_install: funtion to install LEMP stack
# 4. bc_init: function use to call the main part of installation
# 5. bc_main: the main function, add your functions to this place

# Function check user root
bc_checkroot() {
    if (($EUID == 0)); then
        # If user is root, continue to function bc_init
        bc_init
    else
        # If user not is root, print message and exit script
        echo "Bytes Crafter: Please run this script by user root ."
        exit
    fi
}

bc_ssl() {
    echo "Bytes Crafter: Initiating Update ufw..."
    echo ""
    sleep 1
        sudo apt install certbot python3-certbot-nginx -y
    echo ""
    sleep 1
}

bc_ufw() {
    echo "Bytes Crafter: Installing SSL..."
    echo ""
    sleep 1
        sudo ufw allow 22/tcp
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw enable
    echo ""
    sleep 1
}

# Function update os
bc_update() {
    echo "Bytes Crafter: Initiating Update and Upgrade..."
    echo ""
    sleep 1
        sudo apt update
        sudo apt upgrade -y
    echo ""
    sleep 1
}

# Function install LEMP stack
bc_install() {

    ########## INSTALL NGINX ##########
    echo ""
    echo "Bytes Crafter: Installing NGINX..."
    echo ""
    sleep 1
        sudo apt install nginx -y
        sudo ufw allow 'Nginx HTTP'
        sudo systemctl enable nginx && sudo systemctl restart nginx
        sudo chown -R www-data:www-data /var/www/
        sudo chmod -R 777 /var/www/
    echo ""
    sleep 1

    ########## INSTALL MARIADB ##########
    echo "Bytes Crafter: Installing MARIADB..."
    echo ""
    sleep 1
        sudo apt install mariadb-server -y
        sudo systemctl enable mysql && sudo systemctl restart mysql
    echo ""
    sleep 1

    echo "Bytes Crafter: CREATING DB and USER ..."
    echo ""
        mysql -uroot -proot -e "CREATE DATABASE db_nestjs /*\!40100 DEFAULT CHARACTER SET utf8 */;"
        mysql -uroot -proot -e "CREATE USER asean092000@localhost IDENTIFIED BY 'asean092000';"
        mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON asean092000.* TO 'asean092000'@'localhost';"
        mysql -uroot -proot -e "FLUSH PRIVILEGES;"
    echo ""
    sleep 1

    ########## INSTALL Nodejs 18.12.0 ##########
    # This is unofficial repository, it's up to you if you want to use it.
    echo "Bytes Crafter: Installing Nodejs 18.12.0..."
    echo ""
    sleep 1
        sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh
        sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
        sudo source ~/.bashrc
        sudo nvm list-remote
        sudo nvm install v18.12.0
        sudo nvm use v18.12.0
        npm install pm2 -g
        npm install --global yarn
    echo ""
    sleep 1

    ########## ENDING MESSAGE ##########
    sleep 1
    echo ""
        local start="Bytes Crafter: You can access http://"
        local mid=`ip a | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
        echo "Bytes Crafter: $start$mid"
        echo "Bytes Crafter: MySQL db: user: asean092000 pwd: asean092000 "
        echo "Bytes Crafter: Thank you for using our script, Bytes Crafter! ..."
    echo ""
    sleep 1

}

# initialized the whole installation.
bc_init() {
    bc_update
    bc_install
    bc_ufw
    bc_ssl
}

# primary function check.
bc_main() {
    bc_checkroot
}
bc_main
exit