# Automated LXC mailserver container for Proxmox
This repository contains scripts designed to streamline the configuration of a mail server on Debian Linux. These scripts aim to simplify the deployment process, which can be time-consuming when done manually. By executing the debian.sh script within a Proxmox shell (as root), users can set up a basic Debian Linux LXC Container efficiently. Upon completion, the script automatically triggers the configuration of the mail server. During this process, users are prompted to input variables, ensuring accurate placement within the required configuration files.
## Requirements
Before running these scripts, make sure your system meets the following requirements:
- Proxmox Host (tested on PVE 8.1.4)
- Internet connection
- Sufficient permissions (root access).
- curl on Proxmox:
```sh 
apt install curl
```
## Usage
Contains a menu easy script. Start by running in bash as root user:
```sh     
./start.sh
```
Run the following command in Proxmox for Debian LXC:
```sh 
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sjurske/lxcmailserverdeb/main/scripts/debian.sh)"
```
Run the following command in Debian LXC for mailserver:
```sh
apt install -y git && git clone https://github.com/sjurske/lxcmailserverdeb.git && cd lxcmailserverdeb && ./start.sh
```
