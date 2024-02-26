#!/bin/bash

source misc/color.func

check_root() {
    if [ "$(id -u)" != "0" ]; then
        printf "${Red}This script must be run as root${Color_Off}\n\n"
        exit 1
    fi
}

validate_email() {
    local EMAIL=$1
    if [[ "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_database() {
    local DATABASE=$1
    if [[ "$DATABASE" =~ ^[a-zA-Z0-9_]+$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_db_user() {
    local DB_USER=$1
    if [[ "$DB_USER" =~ ^[a-zA-Z0-9_]+$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_yes_no() {
    local input=$1
    if [[ "$input" =~ ^[YyNn]$ ]]; then
        return 0
    else
        return 1
    fi
}

install_proxmox_lxc() {
    printf "Running Proxmox LXC Debian installation script...\n"
    bash scripts/debian.sh
}

install_mailserver() {
    printf "Running mailserver installation script...\n"
    bash scripts/deps.sh
    bash scripts/mailserver.sh
}

main_menu() {
    printf "${BGreen}\n\n-----------------------SCRIPT MENU--------------------------\n\n${Color_Off}"
    printf "1. Install Proxmox LXC Debian\n"
    printf "2. Install Mailserver in a Debian machine\n\n"
    read -p "Enter your choice (1 or 2): " choice
    case $choice in
        1) install_proxmox_lxc ;;
        2) install_mailserver ;;
        *) printf "${Red}Invalid choice. Please enter 1 or 2.${Color_Off}\n\n" ;;
    esac
}

check_root
printf "${Green}Script is running with root privileges${Color_Off}\n\n"

if [[ "$1" == "--proxmox" ]]; then
    read -p "Do you want to install a Debian LXC Container? (Y/N): " lxc_container
    if [[ "$lxc_container" =~ ^[Yy]$ ]]; then
        install_proxmox_lxc
        exit 0
    fi
fi

main_menu