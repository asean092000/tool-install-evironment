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
set -e

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

# Function install ssl
bc_ssl() {
    echo "Bytes Crafter: Installing SSL..."
    echo ""
    sleep 1
        sudo apt install certbot python3-certbot-nginx -y;
        sudo systemctl stop nginx;
        read -p "enter number of site: " END
        START=1
        for i in $(seq $START $END)
        do
        echo "Creating subdomain: $i";
        bc_create_folder
        bc_create_sub
        done
        sudo nginx -t;
        sudo systemctl restart nginx;
        sudo systemctl status certbot.timer;
        sudo certbot renew --dry-run;
    echo "SLL Installed"
    sleep 1
}

# Function create folder to contain source code
bc_create_folder() {
    echo "Creating folder for example.com";
    path="/var/www/";
    index="/index.html";
    while true; do
    read -p "enter directory "  DIR

    if [ -d "$DIR" ]; then
        echo "directory $DIR already exist"
        sleep 1
    else
        sudo mkdir -p $path$DIR
        sudo touch $path$DIR$index
        sudo chmod 777 $path$DIR$index
        sudo cat > $path$DIR$index << EOF
            <!DOCTYPE html>
            <html>
            <head>
                <title>New Page</title>
            </head>
            <body>
                <h1>Hello, World! $DIR</h1>
            </body>
            </html>
EOF
        echo "creating $DIR"
        break
    fi
done
}

# Function create subdomain
bc_create_sub() {
    echo "Creating ssl for example.com";
    path="/etc/nginx/sites-available/";
    index="/index.html"
    enabled="/etc/nginx/sites-enabled/";
    while true; do
    read -p "enter subdomain: "  DIR

    if [ -d "$DIR" ]; then
        echo "subdomain $DIR already exist"
        sleep 1
    else
        sudo touch $path$DIR
        sudo chmod 777 $path$DIR
        sudo cat > $path$DIR << EOF
        server {

            listen 80;

            listen [::]:80;

            root /var/www/$DIR;

            index index.html;

            server_name $DIR;
        }
EOF
        sudo ln -s $path$DIR $enabled$DIR
        echo "Creating $DIR..."
        sudo certbot --nginx -d $DIR
        break
    fi
done
}

# Function enable firewall
bc_ufw() {
    echo "Bytes Crafter: Running firewall"
    sleep 1
        echo "Bytes Crafter: ufw allow 22/tcp..."
        sudo ufw allow 22/tcp
        echo "Bytes Crafter: ufw allow 80/tcp"
        sudo ufw allow 80/tcp
        echo "Bytes Crafter: ufw allow 443/tcp..."
        sudo ufw allow 443/tcp
        echo "Bytes Crafter: ufw enable..."
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
    echo "UPDATE DONE!"
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
        sudo ufw allow 'Nginx Full'
        sudo ufw delete allow 'Nginx HTTP'
        sudo systemctl enable nginx && sudo systemctl restart nginx
        sudo chown -R www-data:www-data /var/www/
        sudo chmod -R 777 /var/www/
        sleep 1

    echo "NGINX installed"
    sleep 1

    ########## INSTALL MYSQL ##########
    echo "Bytes Crafter: Installing MARIADB..."
    echo ""
    sleep 1
        sudo apt update
        sudo apt install mysql-server -y
        sudo systemctl start mysql.service
    echo ""
    sleep 1

    echo "Bytes Crafter: CREATING DB and USER ..."
    echo ""
        sudo mysql -uroot -e "CREATE DATABASE db_nestjs CHARACTER SET utf8 COLLATE utf8_general_ci;"
        sudo mysql -uroot -e "CREATE USER aseanboss@localhost IDENTIFIED WITH mysql_native_password BY  '8y9Z$%XblG%Dm2H6%ooR';"
        sudo mysql -uroot -e "GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'aseanboss'@'localhost' WITH GRANT OPTION;"
        sudo mysql -uroot -e "FLUSH PRIVILEGES;"
    echo "MYSQL Installed"
    sleep 1

    ########## INSTALL Nodejs 18.12.0 ##########
    # This is unofficial repository, it's up to you if you want to use it.
    echo "Bytes Crafter: Installing Nodejs 18.12.0..."
    echo ""
    sleep 1
        # Install node and npm via nvm - https://github.com/creationix/nvm

        # Run this script like - bash script-name.sh

        # Define versions
        local INSTALL_NODE_VER=18.12.0
        local INSTALL_NVM_VER=0.35.3
        local INSTALL_YARN_VER=1.22.19

        # You can pass argument to this script --version 8
        if [ "$1" = '--version' ]; then
            echo "==> Using specified node version - $2"
            INSTALL_NODE_VER=$2
        fi

        echo "==> Ensuring .bashrc exists and is writable"
        touch ~/.bashrc

        echo "==> Installing node version manager (NVM). Version $INSTALL_NVM_VER"
        # Removed if already installed
        rm -rf ~/.nvm
        # Unset exported variable
        export NVM_DIR=

        # Install nvm 
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v$INSTALL_NVM_VER/install.sh | bash
        # Make nvm command available to terminal
        source ~/.nvm/nvm.sh

        echo "==> Installing node js version $INSTALL_NODE_VER"
        nvm install $INSTALL_NODE_VER

        echo "==> Make this version system default"
        nvm alias default $INSTALL_NODE_VER
        nvm use default

        #echo -e "==> Update npm to latest version, if this stuck then terminate (CTRL+C) the execution"
        #npm install -g npm

        echo "==> Installing Yarn package manager"
        rm -rf ~/.yarn
        curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version $INSTALL_YARN_VER

        echo "==> Adding Yarn to environment path"
        # Yarn configurations
        export PATH="$HOME/.yarn/bin:$PATH"
        yarn config set prefix ~/.yarn -g

        echo "==> Checking for versions"
        nvm --version
        node --version
        npm --version
        yarn --version

        echo "==> Print binary paths"
        which npm
        which node
        which yarn

        echo "==> List installed node versions"
        nvm ls

        nvm cache clear
        echo "==> Now you're all setup and ready for development. If changes are yet totake effect, I suggest you restart your computer"

        echo "NODE 18.12.0 installed"

# Tested on Ubuntu, MacOS
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

bc_checkEnv(){
     sleep 1
     echo "Bytes Crafter: Node version"
        node -v
     sleep 1
     echo "Bytes Crafter: mysql version"
        mysql --version
     sleep 1
    echo "Bytes Crafter: nginx version"
        nginx -v
     sleep 1
    echo "Bytes Crafter: yarn version"
        yarn --version
     sleep 1
}
# initialized the whole installation.
bc_init() {
    bc_update
    bc_ufw
    bc_install
    bc_ssl
    bc_checkEnv
}
bc_init
exit