#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/misc/build.func)
# Copyright (c) 2024 Innervate B.V.
# Authors: Reuben Smits & George America
function header_info {
clear
cat <<"EOF"
    CUSTOM DEBIAN LCX
EOF
}
header_info
echo -e "Loading..."
APP="Debian"
var_disk="2"
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
function update_script() {
header_info
if [[ ! -d /var ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated $APP LXC"
exit
}
function run_command_in_container() {
    local container_id="$1"
    local command_to_run="$2"
    pct exec $container_id -- sh -c "$command_to_run"
}
start
build_container
description
msg_ok "Completed Successfully Container!\n\n"
printf "Please continue in LXC Container Shell...\n"