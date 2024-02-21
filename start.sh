#!/bin/bash
source misc/color.func
source /etc/hostname

printf "${BGreen}\n\n-----------------------SCRIPT MENU--------------------------\n\n${Color_Off}"
# Function to check if the script is run with root privileges
check_root() {
    if [ "$(id -u)" != "0" ]; then
        printf "${Red}This script must be run as root${Color_Off}\n\n"
        exit 1
    fi
}

# Call the function to check root privileges
check_root

# Continue with the rest of the script
printf "${Green}Script is running with root privileges${Color_Off}\n\n"

# Function to validate email address
validate_email() {
    local EMAIL=$1
    if [[ "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate database name
validate_database() {
    local DATABASE=$1
    if [[ "$DATABASE" =~ ^[a-zA-Z0-9_]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate database username
validate_db_user() {
    local DB_USER=$1
    if [[ "$DB_USER" =~ ^[a-zA-Z0-9_]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate yes/no input
validate_yes_no() {
    local input=$1
    if [[ "$input" =~ ^[YyNn]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Prompt the user to enter the domain
read -p "Enter Domain Name: " DOMAIN

# Set the domain as the hostname in '/etc/hostname'
echo "$DOMAIN" | tee /etc/hostname

# Set hostname using hostnamectl
hostnamectl set-hostname "$DOMAIN"

# Prompt the user to enter the email address
read -p "Enter E-Mail Address: " EMAIL
while ! validate_email "$EMAIL"; do
    read -p "Invalid input. Please enter a valid E-Mail Address: " EMAIL
done

# Prompt the user to enter the database name
read -p "Enter Database Name: " DATABASE
while ! validate_database "$DATABASE"; do
    read -p "Invalid input. Please enter a valid Database Name: " DATABASE
done

# Prompt the user to enter the database username
read -p "Enter Database Username: " DB_USER
while ! validate_db_user "$DB_USER"; do
    read -p "Invalid input. Please enter a valid Database Username: " DB_USER
done

# Overview of settings
printf "\n\n----------Overview of settings----------\n\n"
printf "${Yellow}Hostname: $DOMAIN\n"
printf "Domain: $DOMAIN\n"
printf "E-Mail Address: $EMAIL\n"
printf "Database Name: $DATABASE\n"
printf "Database User Name: $DB_USER\n\n${Color_Off}"

# Ask the user if the settings are correct
read -p "Are these settings correct? (Y/N): " settings_correct
while ! validate_yes_no "$settings_correct"; do
    read -p "Invalid input. Please enter Y or N: " settings_correct
done

if [[ "$settings_correct" =~ ^[Yy]$ ]]; then
    printf "Great\n"
    printf "Script will now generate corresponding passwords...\n"
    bash scripts/pwgen.sh
else
    # If the settings are not correct, prompt the user to input the values again
    if [[ "$settings_correct" =~ ^[Nn]$ ]]; then
        # Restart from the beginning
        echo "Please input the settings again."
        # You may add code here to reset the hostname if needed
        # If needed, the script could also be modified to store the entered values to avoid re-entering
        continue
    fi
fi

# Ask if nginx needs to be installed
read -p "Do you want to install continue installing mailserver? (Y/N): " install_mailserver
while ! validate_yes_no "$install_mailserver"; do
    read -p "Invalid input. Please enter Y or N: " install_mailserver
done

# If nginx needs to be installed, call nginx.sh script
if [[ "$install_mailserver" =~ ^[Yy]$ ]]; then
    bash scripts/mailserver.sh
fi