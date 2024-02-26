#!/usr/bin/env bash
source misc/color.func
apt update
apt full-upgrade -y
apt install -y mariadb-server mariadb-client postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql certbot
printf "\n\n${BGreen}----SOFTWARE INSTALLED AND UPDATED----${Color_Off}\n\n"