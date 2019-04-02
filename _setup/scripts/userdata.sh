#!/bin/bash

# Initiate Logging

exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

###### Install Ruby START ######

yum install gcc-c++ patch readline readline-devel zlib zlib-devel -y
yum install libyaml-devel libffi-devel openssl-devel make -y
yum install bzip2 autoconf automake libtool bison iconv-devel sqlite-devel -y

curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -L get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm reload
rvm requirements run
rvm install 2.2.4
rvm use 2.2.4 --default

###### Install Ruby END ######

###### Install Wetty START  ######

chmod 755 /root
export HOME=/root
echo "playground    ALL=(ALL)      NOPASSWD: ALL" >> /etc/sudoers

sudo yum update -y
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -  
sudo yum install curl wget nodejs make git nginx -y
sudo yum groupinstall -y 'Development Tools'

cd /opt
git clone https://github.com/krishnasrinivas/wetty.git
cd wetty
npm install --unsafe-perm -g wetty
sudo adduser playground 
echo 'PlaygroundsComputers1' | sudo passwd playground --stdin
sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

sudo service sshd reload

cat <<EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  localhost;
        root         /usr/share/nginx/html;
        location / {
            proxy_pass   http://127.0.0.1:3010;
        }
    }
}
EOF

sudo service nginx start
sudo chkconfig nginx on

sudo -u playground nohup wetty -p 3010 &


###### Install Wetty END  ######


###### Download binaries START  ######

sudo mkdir /home/playground/binaries

cd /home/playground/binaries

wget https://github.com/prometheus/prometheus/releases/download/v2.7.1/prometheus-2.7.1.linux-amd64.tar.gz

wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz

wget https://github.com/juliusv/prometheus_demo_service/releases/download/0.0.4/prometheus_demo_service-0.0.4.linux.amd64.tar.gz

wget https://dl.grafana.com/oss/release/grafana-6.0.0.linux-amd64.tar.gz

wget https://grafana.com/api/dashboards/3662/revisions/2/download -O dashboard.json

sudo chown -R playground /home/playground/binaries
sudo chmod -R 755 /home/playground/binaries


###### Download binaries END  ######



