#!/bin/bash
# This script is to automate the installation of SonarQube local environment
# Dennis Christilaw (2018)
# This code is licensed under the GNU General Public License v3.0

clear
echo "This script will install sonar-scanner environment on your local/dev machine"
echo "This script requires user input, please keep an eye out for the prompts."
echo " "
read -n 1 -s -r -p "Press any key to continue... or ctrl+c to exit..."
cd ~
echo "Installing GoLang"
wget https://dl.google.com/go/go1.10.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.10.linux-amd64.tar.gz
mkdir -p /root/go_projects/{bin,src,pkg}
echo 'PATH=${PATH}:/usr/local/go/bin' >> .bashrc 
echo 'export GOPATH=$HOME/go_projects' >> .bashrc 
echo 'export GOBIN=$GOPATH/bin' >> .bashrc && source .bashrc
echo "Installing GoMetaLinter"
go get -u gopkg.in/alecthomas/gometalinter.v2
mv /root/go_projects/bin/gometalinter.v2 /root/go_projects/bin/gometalinter
sed -i '100s#go/bin#go/bin:/root/go_projects/bin#' .bashrc && source .bashrc
gometalinter --install
echo "Installing Code Coverage Tools"
go get github.com/axw/gocov/...
go get github.com/AlekSi/gocov-xml
echo "Installing Sonar-Scanner"
apt install -y unzip
wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip
unzip sonar-scanner-cli-3.0.3.778-linux.zip -d /usr/local/
mv /usr/local/sonar-scanner-3.0.3.778-linux /usr/local/sonar-scanner
sed -i '100s#go_projects/bin#go_projects/bin:/usr/local/sonar-scanner/bin#' .bashrc && source .bashrc
read -p "What is the SonarQube URL? (Full url with http://ip_add:port/sonar) >> " surl
rm /usr/local/sonar-scanner/conf/sonar-scanner.properties
printf '%s\n' '#----- Default SonarQube server' 'sonar.host.url='${surl} ' ' '#----- Default source code encoding' '#sonar.sourceEncoding=UTF-8' >/usr/local/sonar-scanner/conf/sonar-scanner.properties
clear
echo "###### Local Environment Configuration Completed ####"
