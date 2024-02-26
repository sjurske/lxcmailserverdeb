#!/usr/bin/env bash
source misc/color.func
bash misc/update_sources.sh
apt update
apt full-upgrade -y
apt install -y htop net-tools
printf "\n\n${BGreen}----SOURCES-UPDATED----${Color_Off}\n\n"