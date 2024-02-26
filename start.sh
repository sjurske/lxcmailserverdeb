#!/bin/bash

source misc/color.func

check_root() {
    if [ "$(id -u)" != "0" ]; then
        printf "${Red}Running as root - NO\nExiting Script...${Color_Off}\n\n"
        exit 1
    else
        printf "${Green}Running as root - OK${Color_Off}\n\n"
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
    printf "Running Proxmox LXC Debian installation script...\n\n"
    bash scripts/debian.sh
}

install_mailserver() {
    printf "Installing Mailserver...\n"
    set_variables
    install_mailserver
}

install_nginx() {
    printf "${BRed}FUNCTION NOT COMPLETE${Color_Off}\n"
    main_menu
}

set_variables() {
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
    bash scripts/pwgen.sh
    DB_PASS=$(<db_pw.md)
    E_PASS=$(<e_pw.md)
    PUB_IP=$(curl -s http://ifconfig.me)
    list_variables
}

list_variables() {
    printf "\n----------Overview of settings----------\n\n"
    printf "${Yellow}Hostname: $DOMAIN\n"
    printf "Domain: $DOMAIN\n"
    printf "E-Mail Address: $EMAIL\n"
    printf "E-Mail Password: $E_PASS\n"
    printf "Database Name: $DATABASE\n"
    printf "Database User Name: $DB_USER\n${Color_Off}"
    printf "DB_PASS: $DB_PASS\n"
    read -p "\nAre these settings correct? (Y/N): " settings_correct
    while ! validate_yes_no "$settings_correct"; do
        read -p "Invalid input. Please enter Y or N: " settings_correct
    done
    if [[ "$settings_correct" =~ ^[Yy]$ ]]; then
        printf "Great\n"
        printf "\n${BGreen}Running Mailserver installation script${Color_Off}\n"
        bash scripts/mailserver.sh
        
    else
        printf "Please input the settings again.\n"
        set_variables
    fi
}

main_menu() {
    printf "${BGreen}-----------------------OPTION--------------------------${Color_Off}\n"
    printf "1. Install Debian LXC (HOST ONLY)\n"
    printf "2. Install Postfix & Dovecot Mailserver\n"
    printf "3. Install Nginx Webserver\n\n"
    read -p "Enter your choice: " choice
    case $choice in
        1) install_proxmox_lxc ;;
        2) install_mailserver ;;
        3) install_nginx ;;
        *) printf "${Red}Invalid choice. Please enter correct value${Color_Off}\n\n" ;;
    esac
}
check_root
main_menu