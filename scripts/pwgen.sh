#!/bin/bash
source misc/color.func
# Function to generate a password
generate_password() {
    local seed=$(date +%s%N)
    local password=$(openssl rand -base64 24)
    echo "$password"
}

printf "${Green}\n---------------------Generating Passwords------------------------${Color_Off}\n"
# Generate password for EMAIL_PASS
E_PASS=$(generate_password)
printf "Generated email password: ${UWhite}${E_PASS}${Color_Off}\n"
printf "${E_PASS}" > e_pw.md

# Generate password for DB_PASS
DB_PASS=$(generate_password)
printf "Generated database password: ${UWhite}${DB_PASS}${Color_Off}\n"
printf "${DB_PASS}" > db_pw.md
printf "Output stored in e_pw.md db_pw.md\n"
printf "${BYellow}DELETE OR MOVE THEM TO A SECURE PATH\n\n"
printf "${Green}-----------------Password Generation Completed-------------------${Color_Off}\n\n"