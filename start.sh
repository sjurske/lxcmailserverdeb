#!/bin/bash
source misc/color.func

check_device() {
    if hostnamectl status | grep -q "Virtualization:"; then
        printf "${Green}Virtual Machine: YES${Color_Off}\n\n"
        return 0
    else
        printf "${Red}Virtual Machine: NO${Color_Off}\n\n"
        return 1
    fi
}

check_root() {
    if [ "$(id -u)" != "0" ]; then
        printf "${Red}Running as root: NO\nExiting Script...${Color_Off}\n"
        exit 1
    else
        printf "${Green}Running as root: YES${Color_Off}\n"
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
    printf "${BYellow}Hostname:${Yellow} $DOMAIN\n"
    printf "${BYellow}Domain:${Yellow} $DOMAIN\n"
    printf "${BYellow}E-Mail Address:${Yellow} $EMAIL\n"
    printf "${BYellow}E-Mail Password:${Yellow} $E_PASS\n"
    printf "${BYellow}Database Name:${Yellow} $DATABASE\n"
    printf "${BYellow}Database User Name:${Yellow} $DB_USER\n"
    printf "${BYellow}DB_PASS:${Yellow} $DB_PASS\n\n"
    read -p "Are these settings correct? (Y/N): " settings_correct
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
    check_root
    if check_device; then
        printf "${BGreen}-----------------------OPTION--------------------------${Color_Off}\n"
        printf "2. Install Postfix & Dovecot Mailserver\n"
        printf "3. Install Nginx Webserver\n\n"
        read -p "Enter your choice: " choice
        case $choice in
            2) install_mailserver ;;
            3) install_nginx ;;
            *) printf "${Red}Invalid choice. Please enter correct value${Color_Off}\n\n" ;;
        esac
    else
        printf "${BGreen}-----------------------OPTION--------------------------${Color_Off}\n"
        read -p "Do you want to install a Debian LXC on this host? (Y/N): " install_lxc_choice
        if [[ "$install_lxc_choice" =~ ^[Yy]$ ]]; then
            install_proxmox_lxc
        else
            printf "${Red}Invalid choice. Please enter correct value${Color_Off}\n\n"
        fi
    fi
}

main_menu