#!/usr/bin/env bash
source misc/color.func
apt install -y nginx python3-certbot-nginx php php-fpm
printf "\n\n${BGreen}----SOFTWARE INSTALLED AND UPDATED----${Color_Off}\n\n"