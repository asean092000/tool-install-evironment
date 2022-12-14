#!/bin/bash
set -e

bc_deploy() {
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
    exit
done
}

bc_deploy;