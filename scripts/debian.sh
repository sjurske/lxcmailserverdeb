#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/misc/build.func)
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
  VERB="yes"
  echo_default
}
start
build_container
description
msg_ok "Completed Successfully Containe\n"
printf "${Cyan}Please continue in LXC Container Shell and run this command:${Color_Off}\n"
printf "apt install -y git && git clone https://github.com/sjurske/lxcmailserverdeb.git && cd lxcmailserverdeb && ./start.sh\n\n"