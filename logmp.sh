#!/bin/bash
yum update -y
yum install git -y
cd home/
cd ec2-user/
mkdir entrenamiento
cd entrenamiento/
git clone https://github.com/bortizf/microservice-app-example.git
sudo chmod -R ugo+rwx microservice-app-example/
cd microservice-app-example/log-message-processor/
#install redis
sudo amazon-linux-extras install epel -y
sudo amazon-linux-extras install redis6 -y
sudo systemctl start redis
sudo systemctl enable redis
#install pip
sudo yum install epel-release -y
sudo yum install python-pip -y
pip3 install -r requirements.txt
REDIS_HOST=127.0.0.1 REDIS_PORT=6379 REDIS_CHANNEL=log_channel python3 main.py
