#!/usr/bin/env bash
source misc/color.func
clear
printf "\n${BGreen}-----Running Mailserver installation script-----${Color_Off}\n"
printf "${BGreen}---------Installing & Updating software---------${Color_Off}\n"
bash misc/main_deps.sh
bash misc/update_sources.sh
bash misc/webserver_deps.sh
printf "${BGreen}------Start and enable required services...-----${Color_Off}\n"
systemctl start mariadb && systemctl enable nginx
systemctl start postfix && systemctl enable php-fpm
printf "${BGreen}----------Creating virtual mail user...---------${Color_Off}\n"
read -p "Enter the system webuser (e.g. http, www): " SYS_WEB_USER
read -p "Enable PHP (Y/N): " PHP_ENABLED
mkdir /var/www/$DOMAIN/
mkdir /etc/nginx/sites-available/
touch /etc/nginx/sites-available/$DOMAIN/$DOMAIN.conf

nginxmaincfg=$(cat <<EOF
user                 $SYS_WEB_USER;
pid                  /run/nginx.pid;
worker_processes     auto;
worker_rlimit_nofile 65535;
include              /etc/nginx/modules-enabled/*.conf;
events {
    multi_accept       on;
    worker_connections 65535;
}

http {
    charset                utf-8;
    sendfile               on;
    tcp_nopush             on;
    tcp_nodelay            on;
    server_tokens          off;
    log_not_found          off;
    types_hash_max_size    2048;
    types_hash_bucket_size 64;
    client_max_body_size   16M;

    include                mime.types;
    default_type           application/octet-stream;

    access_log             /var/log/nginx/access.log;
    error_log              /var/log/nginx/error.log;

    ssl_session_timeout    1d;
    ssl_session_cache      shared:SSL:10m;
    ssl_session_tickets    off;
    ssl_protocols          TLSv1.3;
    ssl_stapling           on;
    ssl_stapling_verify    on;

    include                /etc/nginx/conf.d/*.conf;
    include                /etc/nginx/sites-enabled/*;
}
EOF
)
echo "$nginxmaincfg" | tee /etc/nginx/nginx.conf > /dev/null

nginxdomaincfg=$(cat << EOF
server {
    listen                  443 ssl http2;
    listen                  [::]:443 ssl http2;
    server_name             $DOMAIN;
    root                    /var/www/$DOMAIN/public;
    ssl_certificate         /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/$DOMAIN/chain.pem;

	add_header X-XSS-Protection          "1; mode=block" always;
	add_header X-Content-Type-Options    "nosniff" always;
	add_header Referrer-Policy           "no-referrer-when-downgrade" always;
	add_header Content-Security-Policy   "default-src 'self' http: https: ws: wss: data: blob: 'unsafe-inline'; frame-ancestors 'self';" always;
	add_header Permissions-Policy        "interest-cohort=()" always;
	add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

	# . files
	location ~ /\.(?!well-known) {
    	deny all;
	}

    index                   index.html;
    
    location = /favicon.ico {
    	log_not_found off;
    }

	location = /robots.txt {
    	log_not_found off;
	}

	location ~* \.(?:css(\.map)?|js(\.map)?|jpe?g|png|gif|ico|cur|heic|webp|tiff?|mp3|m4a|aac|ogg|midi?|wav|mp4|mov|webm|mpe?g|avi|ogv|flv|wmv)$ {
    	expires 7d;
	}

	location ~* \.(?:svgz?|ttf|ttc|otf|eot|woff2?)$ {
    	add_header Access-Control-Allow-Origin "*";
    expires    7d;
	}

	gzip            on;
	gzip_vary       on;
	gzip_proxied    any;
	gzip_comp_level 6;
	gzip_types      text/plain text/css text/xml application/json application/javascript application/rss+xml application/atom+xml image/svg+xml;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
}

	server {
    listen                  443 ssl http2;
    listen                  [::]:443 ssl http2;
    server_name             *.$DOMAIN;
    ssl_certificate         /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/$DOMAIN/chain.pem;
    return                  301 https://example.com$request_uri;
}

server {
    listen      80;
    listen      [::]:80;
    server_name .$DOMAIN;
    location ^~/.well-known/acme-challenge/ {
    	root /var/www/_letsencrypt;
    }
    location / {
        return 301 https://$DOMAIN/$request_uri;
    }
}
EOF
)
echo "$nginxdomaincfg" | tee /etc/nginx/sites-available/$DOMAIN.conf
ln /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/


#TESTINGPHASE
printf "${Yellow}PRINT IF COMPLETED${Color_Off}"