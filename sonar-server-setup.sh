#!/bin/bash
# This script is to automate the installation of SonarQube Server

echo "This script will install SonarQube Server with Postgres Database inside the Kubernets environment you set up with Kraken"
echo "This script requires user input, please keep an eye out for the prompts."
echo "Be sure to update the password in the .password file (this will be the Postgres Root Password)"
echo " "
read -n 1 -s -r -p "Press any key to continue... or ctrl+c to exit..."
echo "Cloning Repo"
git clone https://github.com/Talderon/k8s-sonarqube.git
cd k8s-sonarqube
echo "Creating Database Password"
kubectl create secret generic postgres-pwd --from-file=./password
echo "Creating SonarQube with Postgres"
kubectl create -f sonar-pv-postgres.yaml
kubectl create -f sonar-pvc-postgres.yaml
kubectl create -f sonar-postgres-deployment.yaml
kubectl create -f sonarqube-deployment.yaml
kubectl create -f sonarqube-service.yaml
kubectl create -f sonar-postgres-service.yaml
echo "Installing Sonar Go Plugin on the Server"
wget https://github.com/uartois/sonar-golang/releases/download/v1.2.10/sonar-golang-plugin-1.2.10.jar
psonar=( $(kubectl get pods -o wide --all-namespaces | grep sonarqube- ) )
kubectl cp sonar-golang-plugin-1.2.10.jar ${psonar[0]}/${psonar[1]}:/opt/sonarqube/extensions/plugins
echo "Assembling Server URL"
echo "You will see a port in the format of: 80:xxxxx, you want to record the port after 80:"
kubectl get svc sonar
echo "Here, you will see the IP Addresses for the Pods (external), normally this installs onto Pod0, but save both in case"
kubectl get pods -o wide --all-namespaces | grep nginx-proxy-local-node-
echo "Use the PodIP and NodePort from above to assemble your URL"
echo "http://{PODIP}:{NodePort}/sonar"
echo "Once in, you will need to install the following plugins (Administration >> Marketplace)"
echo "Checkstyle and SonarJava"
echo "Once installed and verified, restart the server (Administration >> System >> Restart Server button"
read -n 1 -s -r -p "Press any key to continue with the Local Environment Setup... or ctrl+c to exit..."
./local-env-setup.sh