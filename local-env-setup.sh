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
echo 'PATH="$PATH:/usr/local/go/bin:/root/go_projects/bin:/usr/local:/usr/local/sonar-scanner/bin:/usr/local/go/bin:/usr/local/sonar-scanner/bin"' >>/root/.profile
echo 'GOPATH=/root/go_projects'  >>/root/.profile
echo 'GOBIN=$GOPATH/bin' >>/root/.profile
source /root/.profile
echo "Installing GoMetaLinter"
wget https://github.com/alecthomas/gometalinter/releases/download/v2.0.5/gometalinter-2.0.5-linux-amd64.tar.gz
tar -C /root/go_projects/bin -xzf gometalinter-2.0.5-linux-amd64.tar.gz
cd /root/go_projects/bin/gometalinter-2.0.5-linux-amd64
mv /root/go_projects/bin/gometalinter-2.0.5-linux-amd64/* /root/go_projects/bin/
/root/go_projects/bin/gometalinter --install
cd /root
echo "Installing Code Coverage Tools"
go get github.com/axw/gocov/...
go get github.com/AlekSi/gocov-xml
echo "Installing Sonar-Scanner"
apt install -y unzip
wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip
unzip sonar-scanner-cli-3.0.3.778-linux.zip -d /usr/local/
mv /usr/local/sonar-scanner-3.0.3.778-linux /usr/local/sonar-scanner
read -p "What is the SonarQube URL? (Full url with http://ip_add:port/sonar) >> " surl
rm /usr/local/sonar-scanner/conf/sonar-scanner.properties
printf '%s\n' '#----- Default SonarQube server' 'sonar.host.url='${surl} ' ' '#----- Default source code encoding' '#sonar.sourceEncoding=UTF-8' >/usr/local/sonar-scanner/conf/sonar-scanner.properties
clear
cp sonar-project.properties.sample sonar-project.properties
echo "Enter your Project Key and press enter:"
read pjkey
echo "Enter your Project Name and press enter:"
read pjname
sed -i~ -e "s/my:project/${pjkey}/g" sonar-project.properties
sed -i~ -e "s/My_project/${pjname}/g" sonar-project.properties
echo "###### Local Environment Configuration Completed ####"
