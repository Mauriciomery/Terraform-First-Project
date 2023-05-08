#!/bin/bash
yum update -y
yum install git -y
cd home/
cd ec2-user/
touch ansible.txt
mkdir entrenamiento
sudo chmod -R ugo+rwx entrenamiento/
sudo amazon-linux-extras install ansible2 -y
#ansible 2.9.23