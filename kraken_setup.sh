#!/bin/bash
# This script is to automate the installation of Kraken
echo "This script requires user input, please keep an eye out for the prompts."
read -n 1 -s -r -p "Press any key to continue..."
echo "Performing Update"
apt-get -y update
echo "Clone Kraken Repo"
git clone git@gitswarm.f5net.com:blue-ca/kraken.git
echo "Installing Docker"
apt install -y docker.io
echo "Installing Kubectl"
snap install kubectl --classic
echo "Installing JQ"
apt install -y jq
echo "Downloading and installing Certificates"
wget https://weblogin.f5net.com/sso/SE3CIPICA01.F5Net.com_F5_F5NET_Issuing_CA.crt && wget https://weblogin.f5net.com/sso/SE3CIPOCA01_F5_Root_CA.crt
cp SE3CI*.crt /usr/local/share/ca-certificates/
update-ca-certificates
echo "Changing to kraken directory"
cd kraken
echo "The following questions are needed to configure your account info for the build."
echo "You will need the following from VIO dashboard:"
echo " "
echo "1. vio-username (Your vio login name)"
echo "2. vio-password (Your vio password)"
echo "3. vio-project-id (Vio Dashboard: Identity >> Projects ** In the table that is displayed, the NAME column is the Tenant Name and the Project ID is just that."
echo "4. vio-tennant-name (See above)"
read -n 1 -s -r -p "Press any key to continue..."
if read -p "What is your username? : " name; then
  sed -i~ -e "s/<<vio-username>>/${name}/g" target_workspace/terraform_desktop.tfvars
  sed -i~ -e "s/<<username>>/${name}/g" target_workspace/terraform_desktop.tfvars
else
  # Error
fi
if read -p -s "What is your password? : " pass; then
  sed -i~ -e "s/<<vio-password>>/${pass}/g" target_workspace/terraform_desktop.tfvars
else
  # Error
fi
if read -p "What is your project-id? : " pjid; then
  sed -i~ -e "s/<<vio-project-id>>/${pjid}/g" target_workspace/terraform_desktop.tfvars
else
  # Error
fi
if read -p "What is your tenant-name? : " tenant; then
  sed -i~ -e "s/<<vio-tenant-name>>/${tenant}/g" target_workspace/terraform_desktop.tfvars
else
  # Error
fi
echo "Exporting Vault Token"
export VAULT_TOKEN=bb569f0a-a26a-e72b-4fcb-357e53da6cb0
echo "Building Kraken"
apt install -y make
make build
echo "Creating Terraform Plan"
docker run --rm kraken --plan --development --username=${name} --local-tf-vars=../target_workspace/terraform_desktop.tfvars
echo "Running Plan"
docker run --rm kraken --apply --development --username=${name} --local-tf-vars=../target_workspace/terraform_desktop.tfvars
echo "################### Kraken Deployment Completed ###################"
cd /root/SonarQubeAutomation
read -n 1 -s -r -p "Press any key to continue with the Sonar Server Setup... or ctrl+c to exit..."
./sonar-server-setup.sh