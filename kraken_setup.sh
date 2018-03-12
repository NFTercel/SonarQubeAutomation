#!/bin/bash
# This script is to automate the installation of Kraken (this is only useful for F5 Networks)
# This script is not intended for public release!!
# This script will be replaced with MiniKube (local), AWS and Azure variants.
# Dennis Christilaw (2018)

echo "This script requires user input, please keep an eye out for the prompts."
read -n 1 -s -r -p "Press any key to continue..."
echo "Performing Update"
apt-get -y update
echo "Clone Kraken Repo"
git clone git@gitswarm.f5net.com:blue-ca/kraken.git
echo "Installing Docker"
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common make
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get -y update
apt-get install docker-ce
echo "Installing Kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
echo "Installing JQ"
apt install -y jq
echo "Downloading and installing Certificates"
wget https://weblogin.f5net.com/sso/SE3CIPICA01.F5Net.com_F5_F5NET_Issuing_CA.crt && wget https://weblogin.f5net.com/sso/SE3CIPOCA01_F5_Root_CA.crt
cp SE3CI*.crt /usr/local/share/ca-certificates/
update-ca-certificates
rm -f SE3CI*.crt
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
read -p "What is your username? : " name
read -p -s "What is your password? : " pass
read -p "What is your project-id? : " pjid
read -p "What is your tenant-name? : " tenant
sed -i~ -e "s/<<vio-username>>/${name}/g" target_workspace/terraform_desktop.tfvars
sed -i~ -e "s/<<username>>/${name}/g" target_workspace/terraform_desktop.tfvars
sed -i~ -e "s/<<vio-password>>/${pass}/g" target_workspace/terraform_desktop.tfvars
sed -i~ -e "s/<<vio-project-id>>/${pjid}/g" target_workspace/terraform_desktop.tfvars
sed -i~ -e "s/<<vio-tenant-name>>/${tenant}/g" target_workspace/terraform_desktop.tfvars
echo "Exporting Vault Token"
export VAULT_TOKEN=bb569f0a-a26a-e72b-4fcb-357e53da6cb0
echo "Building Kraken"
make build
echo "Creating Terraform Plan"
docker run --rm kraken --plan --development --username=${name} --local-tf-vars=../target_workspace/terraform_desktop.tfvars
echo "Running Terraform Plan - This can take 10+ minutes to run!"
read -n 1 -s -r -p "Press any key to continue..."
docker run --rm kraken --apply --development --username=${name} --local-tf-vars=../target_workspace/terraform_desktop.tfvars
mkdir /root/.kube
curl http://10.145.80.228:8500/v1/kv/Users/${name}/kubernetes/local/managed/config_admin |jq -r '.[]|.Value'|base64 --decode > ~/.kube/config
echo "################### Kraken Deployment Completed ###################"
cd /root/SonarQubeAutomation
read -n 1 -s -r -p "Press any key to continue with the Sonar Server Setup... or ctrl+c to exit..."
./sonar-server-setup.sh
