#!/bin/bash
# This script is to automate the installation of SonarQube Server
# Dennis Christilaw (2018)

echo "This script will install SonarQube Server with Postgres Database inside the Kubernets environment you set up with Kraken"
echo "This script requires user input, please keep an eye out for the prompts."
echo "Be sure to update the password in the .password file (this will be the Postgres Root Password)"
echo " "
read -n 1 -s -r -p "Press any key to continue... or ctrl+c to exit..."
echo "Cloning Repo"
(ssh-agent bash -c 'ssh-add ~/.ssh/github; git clone git@github.com:Talderon/k8s-sonarqube.git')
cd k8s-sonarqube
echo "Creating Database Password"
read -p -s "Enter your Database Password (root) : " dbpass
kubectl create secret generic postgres-pwd --from-literal=password=${dbpass}
echo "Creating SonarQube with Postgres"
kubectl create -f sonar-pv-postgres.yaml
kubectl create -f sonar-pvc-postgres.yaml
kubectl create -f sonar-postgres-deployment.yaml
kubectl create -f sonarqube-deployment.yaml
kubectl create -f sonarqube-service.yaml
kubectl create -f sonar-postgres-service.yaml
cd ..
echo "Downloading and Installing Sonar Go Plugin on the Server"
wget https://github.com/uartois/sonar-golang/releases/download/v1.2.11/sonar-golang-plugin-1.2.11.jar
psonar=( $(kubectl get pods -o wide --all-namespaces | grep sonarqube- ) )
kubectl cp sonar-golang-plugin-1.2.11.jar ${psonar[1]}:/opt/sonarqube/extensions/plugins/
echo "Assembling Server URL"
echo "Here, you will see the IP Addresses for the Pod (external) Sonarqube is deployed too."
echo "Note the URLS's for both nodes"
kubectl describe pods sonarqube | grep Node:
read -n 1 -s -r -p "Press any key to continue..."
echo "You will see a port in the format of: 80:xxxxx, you want to record the port after 80:"
kubectl get all | grep NodePort
read -n 1 -s -r -p "Press any key to continue..."
clear
echo "Save this URL as you will need it later for your local environment setup!"
echo "Use the PodIP and NodePort from above to assemble your URL"
echo "http://{PODIP}:{NodePort}/sonar"
echo "Default login is admin/admin"
echo "Once in, you will need to install the following plugins (Administration >> Marketplace)"
echo "Checkstyle and SonarJava"
echo "Verify that the GoLang plugin is installed"
echo "Once installed and verified, restart the server (Administration >> System >> Restart Server button)"
echo " "
echo "##### Completed SonarQube Server Sertup #####"
read -n 1 -s -r -p "Press any key to continue with the Local Environment Setup... or ctrl+c to exit..."
cd /root/SonarQubeAutomation
./local-env-setup.sh