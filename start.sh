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
    set_variables
}

set_variables() {
    clear
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
    clear 
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
        ##ENTER TO CONTINUE
        printf "${Yellow}   ----------------------------------------   ${Color_Off}\n"
        printf "${Yellow}|      BEFORE YOU CONTINUE PLEASE            |${Color_Off}\n"
        printf "${Yellow}|      MAKE SURE YOU HAVE A VALID DOMAIN     |${Color_Off}\n"
        printf "${Yellow}|      CONFIGURE YOUR DNS PROPERLY           |${Color_Off}\n"
        printf "${Yellow}|      AND PORT FORWARD THESE PORTS:         |${Color_Off}\n"
        printf "${Yellow}|       - 25                                 |${Color_Off}\n"
        printf "${Yellow}|       - 80                                 |${Color_Off}\n"
        printf "${Yellow}|       - 110                                |${Color_Off}\n"
        printf "${Yellow}|       - 143                                |${Color_Off}\n"
        printf "${Yellow}|       - 443                                |${Color_Off}\n"
        printf "${Yellow}|       - 465                                |${Color_Off}\n"
        printf "${Yellow}|       - 587                                |${Color_Off}\n"
        printf "${Yellow}|       - 993                                |${Color_Off}\n"
        printf "${Yellow}|       - 995                                |${Color_Off}\n"
        printf "${Yellow}|       - (optional) 22                      |${Color_Off}\n"
        printf "${Yellow}   ----------------------------------------   ${Color_Off}\n\n"
        printf "${Green} - PRESS ENTER TO CONTINUE: ${Color_Off}\n\n"
        read -p ""
        export DOMAIN EMAIL DATABASE DB_USER DB_PASS E_PASS PUB_IP
        if [ "$choice" -eq 2 ]; then
            bash scripts/mailserver.sh
        elif [ "$choice" -eq 3 ]; then
            bash scripts/nginx.sh
        else
            printf "${Red}Invalid choice. Please enter correct value${Color_Off}\n\n"
        fi
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
        read -p "Do you want to install a Debian LXC on this host? (Y/N): " install_lxc_choice
        if [[ "$install_lxc_choice" =~ ^[Yy]$ ]]; then
            install_proxmox_lxc
        else
            printf "${Red}Invalid choice. Please enter correct value${Color_Off}\n\n"
        fi
    fi
}

main_menu