#!/bin/bash
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
        read -p "enter number of site: " END
        START=1
        for i in $(seq $START $END)
        do
        echo "Creating subdomain: $i";
        bc_create_folder
        bc_create_sub
        done
    sudo systemctl status certbot.timer
    sudo certbot renew --dry-run
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
        sudo nginx -t
        sudo systemctl reload nginx
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

########## INSTALL Nodejs 18.12.0 ##########
bc_nodejs() {
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
}

########## INSTALL MYSQL ##########
bc_mysql() {
    echo "Bytes Crafter: Installing MYSQL..."
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
}

########## INSTALL NGINX ##########
bc_nginx () {
    echo ""
    echo "Bytes Crafter: Installing NGINX..."
    echo ""
    sleep 1
        sudo apt install nginx -y
        sudo ufw allow 'Nginx Full'
        sudo ufw delete allow 'Nginx HTTP'
        sudo ufw status
        sudo systemctl enable nginx && sudo systemctl restart nginx
        sudo chown -R www-data:www-data /var/www/
        sudo chmod -R 777 /var/www/
        sleep 1

    echo "NGINX installed"
    sleep 1
}

########## ENDING MESSAGE ##########
bc_message(){
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

########## CHECK ENVIRONMENTS ##########
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

########## INSTALL PORT OF APP ##########
bc_install_port() {
    path="/etc/nginx/sites-available/";
    index="/index.html"
    enabled="/etc/nginx/sites-enabled/";
    while true; do
    read -p "enter subdomain: "  DIR
    read -p "enter port's running: "  PORT
    check=$enabled$DIR
    sudo rm $check
    echo "Starting update port...";
    sleep 2
    sudo touch $path$DIR
    sudo chmod 777 $path$DIR
    sudo cat > $path$DIR << EOF
        server {
            root /var/www/$DIR;
            index index.html;
            server_name $DIR;
            listen [::]:443 ssl; # managed by Certbot
            listen 443 ssl; # managed by Certbot
            ssl_certificate /etc/letsencrypt/live/$DIR/fullchain.pem; # managed by Certbot
            ssl_certificate_key /etc/letsencrypt/live/$DIR/privkey.pem; # managed by Certbot
            include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
            ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

            location / {
                proxy_pass http://localhost:$PORT;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $(echo "$")http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $(echo "$")host;
                proxy_cache_bypass $(echo "$")http_upgrade;
            }
        }
        server {
            if ($(echo "$")host = $DIR) {
                return 301 https://$(echo "$")host$(echo "$")request_uri;
            } # managed by Certbot
            listen 80;
            listen [::]:80;
            server_name $DIR;
            return 404; # managed by Certbot
        }
EOF
    sudo ln -s $path$DIR $enabled$DIR
    sudo nginx -t
    sudo systemctl reload nginx
    bc_reboot
done
}

bc_reboot() {
    echo "yes/no"
    read -p "System needs to reboot : " END
    if [ $END == 'yes' ]
    then
        sudo reboot
    elif [ $END == 'no' ]
    then
        exit
    else
       echo "Must be correct...";
       bc_reboot
    fi
}

bc_ask_port() {
    echo "yes/no"
    read -p "Do you want to install port apps: " END
    if [ $END == 'yes' ]
    then
        bc_install_port
    elif [ $END == 'no' ]
    then
        bc_reboot
    else
       echo "Must be correct..."
       bc_ask_port
    fi
}
# Function install LEMP stack
bc_install() {
    bc_nodejs
    bc_nginx
    bc_mysql
    bc_ssl
}

# initialized the whole installation.
bc_init() {
    read -p "Choose 1: Install environment 2: Install port 3: exit" END
    if [ $END == 1 ]
    then
        bc_update
        bc_ufw
        bc_install
    elif [ $END == 2 ]
    then
        bc_checkEnv
        bc_ask_port
    elif [ $END == 3 ]
    then
       exit
    else
       echo "Must be correct..."
    fi
    bc_init
}
bc_init