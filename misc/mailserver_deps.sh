#!/usr/bin/env bash
source misc/color.func
apt install -y mariadb-server mariadb-client postfix postfix-mysql policycoreutils-python-utils dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql
printf "${BGreen}---------SOFTWARE INSTALLED AND UPDATED---------${Color_Off}\n"