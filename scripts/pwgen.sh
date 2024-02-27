#!/bin/bash
source misc/color.func
generate_password() {
    local seed=$(date +%s%N)
    local password=$(openssl rand -base64 24)
    echo "$password"
}
printf "${BGreen}-------------GENERATING PASSWORDS---------------${Color_Off}\n\n"
E_PASS=$(generate_password)
printf "E-Mail Password: ${UWhite}${E_PASS}${Color_Off}\n"
printf "${E_PASS}" > e_pw.md
DB_PASS=$(generate_password)
printf "Database Password: ${UWhite}${DB_PASS}${Color_Off}\n"
printf "${DB_PASS}" > db_pw.md
printf "${Cyan}Stored in 'e_pw.md' 'db_pw.md'\n"
printf "${BYellow}DELETE OR MOVE THEM TO A SECURE PATH\n"
printf "\n${BGreen}--------------PASSWORDS GENERETED---------------${Color_Off}\n\n"
printf "${Green} - PRESS ENTER TO CONTINUE: ${Color_Off}\n"
read -p ""