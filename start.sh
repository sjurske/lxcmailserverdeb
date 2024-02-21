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
    local email=$1
    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate database name
validate_database() {
    local database=$1
    if [[ "$database" =~ ^[a-zA-Z0-9_]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate database username
validate_db_user() {
    local db_user=$1
    if [[ "$db_user" =~ ^[a-zA-Z0-9_]+$ ]]; then
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
echo "$DOMAIN" | sudo tee /etc/hostname

# Set hostname using hostnamectl
sudo hostnamectl set-hostname "$DOMAIN"

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
echo "Overview of settings:"
echo "Hostname: $DOMAIN"
echo "Domain: $DOMAIN"
echo "E-Mail Address: $EMAIL"
echo "Database Name: $DATABASE"
echo "Database User Name: $DB_USER"

# Ask the user if the settings are correct
read -p "Are these settings correct? (Y/N): " settings_correct
while ! validate_yes_no "$settings_correct"; do
    read -p "Invalid input. Please enter Y or N: " settings_correct
done

if [[ "$settings_correct" =~ ^[Yy]$ ]]; then
    bash scripts/pwgen.sh

# If the settings are not correct, prompt the user to input the values again
if [[ "$settings_correct" =~ ^[Nn]$ ]]; then
    # Restart from the beginning
    echo "Please input the settings again."
    # You may add code here to reset the hostname if needed
    # If needed, the script could also be modified to store the entered values to avoid re-entering
    exit 1
fi

# Call mailserver.sh script
bash mailserver.sh

# Ask if nginx needs to be installed
read -p "Do you want to install nginx? (Y/N): " install_nginx
while ! validate_yes_no "$install_nginx"; do
    read -p "Invalid input. Please enter Y or N: " install_nginx
done

# If nginx needs to be installed, call nginx.sh script
if [[ "$install_nginx" =~ ^[Yy]$ ]]; then
    bash nginx.sh
fi
