#!/bin/bash
yum update -y
yum install git -y
cd home/
cd ec2-user/
mkdir entrenamiento
cd entrenamiento/
sudo git clone https://github.com/bortizf/microservice-app-example.git
sudo chmod -R ugo+rwx microservice-app-example/
cd microservice-app-example/todos-api/
#instalando nvm
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#instalando la version correcta de Node y NPM
nvm install node
nvm install 8.17.0
nvm use 8.17.0
#building
npm install
npm audit fix
npm install node-fetch@2.6.1
JWT_SECRET=PRFT TODO_API_PORT=8082 npm start&
#npm audit fix --force