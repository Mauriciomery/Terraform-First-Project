#!/bin/bash
yum update -y
yum install git -y
cd home/
cd ec2-user/
mkdir entrenamiento
cd entrenamiento/
git clone https://github.com/bortizf/microservice-app-example.git
sudo chmod -R ugo+rwx microservice-app-example/
yum install curl -y
sudo curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.17.0
nvm use 8.17.0
npm install
npm audit fix
npm run build
PORT=9050 AUTH_API_ADDRESS=http://internal-MM-Internal-LB-2051230687.us-east-1.elb.amazonaws.com:8020 TODOS_API_ADDRESS=http://internal-MM-Internal-LB-2051230687.us-east-1.elb.amazonaws.com:8082 npm start&