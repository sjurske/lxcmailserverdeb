#!/usr/bin/env bash
source misc/color.func
apt update
apt full-upgrade -y
apt install -y nginx python3-certbot-nginx php
printf "\n\n${BGreen}----SOFTWARE INSTALLED AND UPDATED----${Color_Off}\n\n"