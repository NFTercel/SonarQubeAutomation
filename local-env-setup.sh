#!/bin/bash
# This script is to automate the installation of SonarQube local environment

echo "This script will install sonar-scanner environment on your local/dev machine"
echo "This script requires user input, please keep an eye out for the prompts."
echo " "
read -n 1 -s -r -p "Press any key to continue... or ctrl+c to exit..."
echo "Installing GoLang"
wget https://dl.google.com/go/go1.10.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.10.linux-amd64.tar.gz
mkdir -p ~/go_projects/{bin,src,pkg}
printf '%s\n' 'PATH DEFAULT=${PATH}:/usr/local/go/bin' 'export GOPATH="$HOME/go_projects"' 'export GOBIN="$GOPATH/bin"' >.pam_environment && source .pam_environment
echo "Installing GoMetaLinter"
go get -u gopkg.in/alecthomas/gometalinter.v2
mv ~/go/bin/gometalinter.v2 ~/go/bin/gometalinter
gometalinger --install
echo "Installing Sonar-Scanner"
read -p "What is the SonarQube URL? (Full url with http://ip_addy:port/sonar)" surl
printf '%s\n' '#----- Default SonarQube server' 'sonar.host.url='${surl} ' ' '#----- Default source code encoding' '#sonar.sourceEncoding=UTF-8' >/usr/local/sonar-scanner/conf/sonar-scanner.properties
