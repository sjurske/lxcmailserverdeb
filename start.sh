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

# Get the current hostname
current_hostname=$(cat /etc/hostname)

# Prompt the user to check the current hostname
read -p "Is the current hostname '$current_hostname' correct? (Y/N): " hostname_correct
while ! validate_yes_no "$hostname_correct"; do
    read -p "Invalid input. Please enter Y or N: " hostname_correct
done

# If the hostname is not correct, prompt the user to enter the new hostname
if [[ "$hostname_correct" =~ ^[Nn]$ ]]; then
    read -p "Enter the new hostname: " myhostname
    sudo hostnamectl set-hostname "$myhostname"
    echo "Hostname changed to $myhostname"
else
    myhostname=$current_hostname
fi

# Prompt the user to enter the email address
read -p "Enter EMAIL: " EMAIL
while ! validate_email "$EMAIL"; do
    read -p "Invalid input. Please enter a valid EMAIL: " EMAIL
done

# Prompt the user to enter the database name
read -p "Enter DATABASE: " DATABASE
while ! validate_database "$DATABASE"; do
    read -p "Invalid input. Please enter a valid DATABASE: " DATABASE
done

# Prompt the user to enter the database username
read -p "Enter DB_USER: " DB_USER
while ! validate_db_user "$DB_USER"; do
    read -p "Invalid input. Please enter a valid DB_USER: " DB_USER
done

# Overview of settings
bash pwgen.sh
echo "Overview of settings:"
echo "Hostname: $myhostname"
echo "EMAIL: $EMAIL"
echo "DATABASE: $DATABASE"
echo "DB_USER: $DB_USER"

# Ask the user if the settings are correct
read -p "Are these settings correct? (Y/N): " settings_correct
while ! validate_yes_no "$settings_correct"; do
    read -p "Invalid input. Please enter Y or N: " settings_correct
done

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