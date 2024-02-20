# Automated LXC mailserver Container for Proxmox
This repository contains scripts designed to streamline the configuration of a mail server on Debian Linux. These scripts aim to simplify the deployment process, which can be time-consuming when done manually. By executing the debian.sh script within a Proxmox shell (as root), users can set up a basic Debian Linux LXC Container efficiently. Upon completion, the script automatically triggers the configuration of the mail server. During this process, users are prompted to input variables, ensuring accurate placement within the required configuration files.
## Scripts
- `debian.sh`: Creates a LXC container in Proxmox.
- `mailserver.sh`: Install and setup a mailserver inside Debian.
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
| **curl**  | `bash -c "$(curl -fsSL https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/debian.sh`     |
| **wget**  | `bash -c "$(wget -O- https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/debian.sh)"`     |
| **fetch** | `bash -c "$(fetch -o - https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/debian.sh)"`   |
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
