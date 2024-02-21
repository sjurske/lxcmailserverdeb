# Automated LXC mailserver container for Proxmox
NOTE: THIS IS STILL A WIP PROJECT - README NOT UP TO DATE!
This repository contains scripts designed to streamline the configuration of a mail server on Debian Linux. These scripts aim to simplify the deployment process, which can be time-consuming when done manually. By executing the debian.sh script within a Proxmox shell (as root), users can set up a basic Debian Linux LXC Container efficiently. Upon completion, the script automatically triggers the configuration of the mail server. During this process, users are prompted to input variables, ensuring accurate placement within the required configuration files.
## Scripts
- `debian.sh`: Creates a LXC container in Proxmox.
- `mailserver.sh`: Install and setup a mailserver inside Debian.
- `nginx.sh`: Install and setup a nginx webserver.

## Requirements
Before running these scripts, make sure your system meets the following requirements:
- Proxmox Host (tested on PVE 8.1.4)
- Internet connection
- Sufficient permissions (root access).
- Install curl on Proxmox:
```sh 
apt update && apt install curl
```

## Usage
Run the following command in Proxmox:
```sh 
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sjurske/lcxmailserverdeb/main/debian.sh
```
