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
    printf "Installing Mailserver...\n"
    read -p "Enter Domain Name: " DOMAIN
    echo "$DOMAIN" | tee /etc/hostname
    hostnamectl set-hostname "$DOMAIN"
    read -p "Enter E-Mail Address: " EMAIL
    while ! validate_email "$EMAIL"; do
        read -p "Invalid input. Please enter a valid E-Mail Address: " EMAIL
    done
    read -p "Enter Database Name: " DATABASE
    while ! validate_database "$DATABASE"; do
        read -p "Invalid input. Please enter a valid Database Name: " DATABASE
    done
    read -p "Enter Database Username: " DB_USER
    while ! validate_db_user "$DB_USER"; do
        read -p "Invalid input. Please enter a valid Database Username: " DB_USER
    done

    printf "\n\n----------Overview of settings----------\n\n"
    printf "${Yellow}Hostname: $DOMAIN\n"
    printf "Domain: $DOMAIN\n"
    printf "E-Mail Address: $EMAIL\n"
    printf "Database Name: $DATABASE\n"
    printf "Database User Name: $DB_USER\n\n${Color_Off}"
    read -p "Are these settings correct? (Y/N): " settings_correct
    while ! validate_yes_no "$settings_correct"; do
        read -p "Invalid input. Please enter Y or N: " settings_correct
    done
    if [[ "$settings_correct" =~ ^[Yy]$ ]]; then
        printf "Great\n"
        printf "Script will now generate corresponding passwords...\n\n"
        bash scripts/pwgen.sh
        bash scripts/mailserver.sh
    else
        printf "Please input the settings again.\n"
        install_mailserver
    fi
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

main_menu