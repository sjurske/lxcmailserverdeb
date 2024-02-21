#!/usr/bin/env bash
source ../misc/color.func
new_sources_list="
deb http://deb.debian.org/debian bookworm main non-free-firmware
deb-src http://deb.debian.org/debian bookworm main non-free-firmware
deb http://deb.debian.org/debian-security/ bookworm-security main non-free-firmware
deb-src http://deb.debian.org/debian-security/ bookworm-security main non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main non-free-firmware
deb-src http://deb.debian.org/debian bookworm-updates main non-free-firmware"
echo "$new_sources_list" | sudo tee /etc/apt/sources.list > /dev/null
apt update
apt full-upgrade -y
apt install -y net-tools mariadb-server mariadb-client postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql