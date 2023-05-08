#!/bin/bash
yum update -y
yum install git -y
cd home/
cd ec2-user/
mkdir entrenamiento
cd entrenamiento/
git clone https://github.com/bortizf/microservice-app-example.git
sudo chmod -R ugo+rwx microservice-app-example/
cd microservice-app-example/auth-api/
yum install curl -y
sudo yum install golang -y
#Building
echo "-----------Empezando a buildear con GO ------------"
export GO111MODULE=on
go mod init github.com/bortizf/microservice-app-example/tree/master/auth-api
sudo go mod tidy
sudo go build
#Running
echo "*****------Corriendo Auth api -----*****"
JWT_SECRET=PRFT AUTH_API_PORT=8020 USERS_API_ADDRESS=http://internal-MM-Internal-LB-2051230687.us-east-1.elb.amazonaws.com:8083 ./auth-api
#JWT_SECRET=PRFT AUTH_API_PORT=8030 USERS_API_ADDRESS=http://10.0.1.223:8083 ./auth-api
#curl -X POST  http://10.0.1.53:8030/login -d '{"username": "admin","password": "admin"}'
#curl -X POST internal-MM-Internal-LB-2051230687.us-east-1.elb.amazonaws.com:8030/login -d '{"username": "admin","password": "admin"}'