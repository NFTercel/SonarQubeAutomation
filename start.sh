#!/bin/bash
# This script is to automate the installation of Kraken
# Dennis Christilaw (2018)

clear
echo "In order to complete this deployment process, you must have the following configured:"
echo " "
echo "1. A small instance in VIO (These instructions assume Ubuntu 16.0.4 LTS Pristine image)."
echo "2. Access to F5 VPN (Even while in Corp Office, you need to be on VPN for access to the proper subnet)."
echo "3. Run these scripts from your local or dev machines."
echo "4. SSH to your new instance and add the hostname to your /etc/hosts file ( 127.0.0.1	{hostname} )."
echo "5. (new instance) Add the SSH Key you created for VIO to this node (be sure to chmod 600 ~/.ssh/your_key)."
echo "6. (new instance) Add your GitLab SSH Key to this node with the filename id_rsa (be sure to chmod 600 ~/.ssh/id_rsa)."
echo " "
echo "These scripts, at times, will need user input. You'll want to watch for these pauses."
while true; do
    read -p "Continue with the deplopyment? (y)es or (n)o >> " yn
    case $yn in
        [Yy]* ) echo "Deployment Starting" && ./kraken_setup.sh; break;;
        [Nn]* ) echo "Deployment Cancelled" && exit;;
        * ) echo "Please answer (y)es or (n)o.";;
    esac
done