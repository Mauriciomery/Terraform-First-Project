#!/bin/bash
yum update -y
yum install git -y
cd home/
cd ec2-user/
mkdir entrenamiento
cd entrenamiento/
git clone https://github.com/bortizf/microservice-app-example.git
sudo chmod -R ugo+rwx microservice-app-example/
cd microservice-app-example/users-api/
yum install curl -y
sudo amazon-linux-extras enable corretto8
sudo yum install java-1.8.0-amazon-corretto -y
sudo yum install java-1.8.0-amazon-corretto-devel -y
sudo alternatives --config java
1
sudo alternatives --config javac
1
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto.x86_64
sudo wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install -y apache-maven
./mvnw clean install
JWT_SECRET=PRFT SERVER_PORT=8083 java -jar target/users-api-0.0.1-SNAPSHOT.jar
#curl -X GET -H "Authorization: Bearer $token" http://10.0.1.223:8083/users/admin