#!/usr/bin/env bash
source misc/build.func
source misc/color.func
function header_info {
clear
cat << EOF
CUSTOM DEBIAN LCX
EOF
}
header_info
echo -e "Loading..."
APP="Debian"
var_disk="4"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="12"
variables
color
catch_errors
function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="yes"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}
start
build_container
description
msg_ok "Completed Successfully Containe\n"
printf "${White}Please continue in LXC Container Shell and run this command:${Color_Off}\n"
printf "${UCyan}apt install -y git && git clone https://github.com/sjurske/lxcmailserverdeb.git && cd lxcmailserverdeb && ./start.sh${Color_Off}\n\n"