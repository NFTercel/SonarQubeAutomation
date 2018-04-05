#!/bin/bash
# This script is to automate the installation of SonarQube Server
# Kubernetest Cluster is required before continuing
# Dennis Christilaw (2018)
# This code is licensed under the GNU General Public License v3.0

clear
echo "This script will install SonarQube Server with Postgres Database inside the Kubernets environment you set up."
echo "This script requires user input, please keep an eye out for the prompts."
echo "If you plan to use SSH Git Commands, you will need to do the following:"
echo "It is recomended that you fork this repo (https://github.com/Talderon/k8s-sonarqube) so you can make modifications as needed."
echo "Be sure to have your github ssh key in the ~/.ssh directory."
echo "Other option will be to clone via HTTPS which this script is not set up for."
echo " "
read -n 1 -s -r -p "Press any key to continue... or ctrl+c to exit..."
echo "Cloning Repo"
read -p "What is the name of your github private ssh key (must be in the ~/.ssh directory)? : " gitkey
read -p "What is the name of your github user name? : " guser
(ssh-agent bash -c 'ssh-add ~/.ssh/${gitkey}; git clone git@github.com:${guser}/k8s-sonarqube.git')
cd k8s-sonarqube
echo "Enter your Database Root Password and press enter: "
read -s dbpass
kubectl create secret generic postgres-pwd --from-literal=password=$dbpass
unset dbpass
echo "Creating SonarQube with Postgres"
kubectl create -f sonar-pv-postgres.yaml -n default
kubectl create -f sonar-pvc-postgres.yaml -n default
kubectl create -f sonar-postgres-deployment.yaml -n default
kubectl create -f sonarqube-deployment.yaml -n default
kubectl create -f sonarqube-service.yaml -n default
kubectl create -f sonar-postgres-service.yaml -n default
cd ..
echo "Downloading and Installing Plugins on the Server"
wget https://github.com/uartois/sonar-golang/releases/download/v1.2.11/sonar-golang-plugin-1.2.11.jar
wget https://github.com/checkstyle/sonar-checkstyle/releases/download/4.8/checkstyle-sonar-plugin-4.8.jar
wget https://github.com/SonarQubeCommunity/sonar-build-breaker/releases/download/2.2/sonar-build-breaker-plugin-2.2.jar
wget https://github.com/QualInsight/qualinsight-plugins-sonarqube-badges/releases/download/qualinsight-plugins-sonarqube-badges-3.0.1/qualinsight-sonarqube-badges-3.0.1.jar
wget https://sonarsource.bintray.com/Distribution/sonar-javascript-plugin/sonar-javascript-plugin-4.1.0.6085.jar
wget https://sonarsource.bintray.com/Distribution/sonar-java-plugin/sonar-java-plugin-5.1.1.13214.jar
wget https://sonarsource.bintray.com/Distribution/sonar-xml-plugin/sonar-xml-plugin-1.4.3.1027.jar
wget https://github.com/SonarSource/sonar-ldap/releases/download/2.2-RC3/sonar-ldap-plugin-2.2.0.601.jar
psonar=( $(kubectl get pods -o wide --all-namespaces | grep sonarqube- ) )
kubectl cp *.jar ${psonar[1]}:/opt/sonarqube/extensions/plugins/
echo "Assembling Server URL"
echo "Here, you will see the IP Addresses for the Pod (external) Sonarqube is deployed too."
echo "Note the URLS's for all pods if you are not sure which pod is being deployed too."
kubectl describe pods sonarqube | grep Node:
read -n 1 -s -r -p "Press any key to continue..."
echo "You will see a port in the format of: 80:xxxxx, you want to record the port after 80:"
kubectl get all | grep NodePort
echo "Save this URL outside this terminal window."
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
