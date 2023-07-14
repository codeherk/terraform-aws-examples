#!/bin/bash
sudo su root
apt update -y
apt install golang -y
apt install mysql-client-core-8.0 -y
apt install awscli -y 
export GOROOT=/usr/lib/golang
export GOPATH=$HOME/go-api-example
export PATH=$PATH:$GOROOT/bin
git clone https://github.com/codeherk/go-api-example /home/ubuntu/go-api-example
git checkout post-tasks
DB_PASSWORD=$(aws ssm get-parameter --name ${DB_PASSWORD_PARAM} --region us-east-1 --with-decryption --output text --query Parameter.Value)
mysql -h ${DB_HOST} -u ${DB_USER} ${DB_NAME} -p$DB_PASSWORD < /home/ubuntu/go-api-example/init.sql 
cd /home/ubuntu/go-api-example/ && sudo go build -buildvcs=false
MYSQL_USER=${DB_USER} MYSQL_PASSWORD=$DB_PASSWORD MYSQL_HOST=${DB_HOST} MYSQL_PORT=${DB_PORT} MYSQL_DATABASE=${DB_NAME} ./go-api-example