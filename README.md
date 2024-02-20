# LCX Mail Server Debian Scripts

This repository contains scripts for setting up a mail server on Debian.

## Scripts
- `debian.sh`: Creates a LCX container.
- `mailserver.sh`: Install and setup a postfix & dovecot mailserver.
- `nginx.sh`: Install and setup a nginx webserver.

## Requirements
Before running these scripts, make sure your system meets the following requirements:
- Debian operating system.
- Internet connection to download necessary packages and updates.
- Sufficient permissions to execute scripts.

## Usage
To use the scripts, choose one of the following methods:
### Debian LCX 
| Method    | Command                                                                                               |
| :-------- | :---------------------------------------------------------------------------------------------------: |
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/debian.sh)"`     |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/debian.sh)"`       |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/debian.sh)"`     |
### Mailserver 
| Method    | Command                                                                                               |
| :-------- | :---------------------------------------------------------------------------------------------------: |
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/mailserver.sh)"` |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/mailserver.sh)"`   |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/mailserver.sh)"` |
### Nginx 
| Method    | Command                                                                                               |
| :-------- | :---------------------------------------------------------------------------------------------------: |
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/nginx.sh)"`      |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/nginx.sh)"`        |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/nginx.sh)"`      |
