pipeline {
    agent any

    stages {
        stage('Terraform Verification') {
            steps {
                sh 'pwd'
                //  /var/lib/jenkins/workspace/First-PR-Pipeline
                echo 'Aqui estamos'
                sh 'ls'
                echo 'Esos son los archivos que hay por el momento'
                sh 'cat Jenkinsfile'
                //sh 'terraform init'
                //sh 'terraform validate'
            }
        }
        stage('Verify Tag') {
            steps {
                sh 'grep -q "mauricio.merya" main.tf'
                sh 'grep -i "mauricio.merya" main.tf'
                echo 'Llegamos hasta validar tag' 
                
            }
        }
        stage('Handle Result') {
            steps {
                 script {
                    if (sh(returnStatus: true, script: 'grep -q "mauricio.merya" main.tf') == 0) {
                        echo 'Tag verification passed!'
                     } else {
                        error 'Tag verification failed!'
                     }
                }
                echo 'manejar resultado de busqueda de tag' 
            }
        }
        stage('Build') {
            steps {
                // Add build steps as necessary
                echo "Aqui se entra a una EC2 instance del FRONT"
                echo "Intentando desde la carpeta de entrenamiento"
                sh 'cd $HOME'
                sh 'ls'
                sh 'ssh -i "rampup-mery2.pem" ec2-user@10.0.101.65'
                sh 'pwd'
                sh 'ls'
                sh 'touch test1PipelineConnect.txt'
                sh 'logout' 
                echo 'aqui se salió de la maquina'
            }
        }
        stage('Accept and Merge Pull Request') {
            steps {
                script {
                    def gitUrl = env.GIT_URL.replace("https://", "https://$env.GITHUB_TOKEN@")
                    sh "git config --global user.email 'mauricio.mery0527@gmail.com'"
                    sh "git config --global user.name 'Mauriciomery'"
                    sh "git clone $gitUrl repositorio"
                    sh "git checkout ${env.GIT_BRANCH}"
                    sh "git merge --no-ff ${env.GIT_COMMIT}"
                    sh "git push $gitUrl HEAD:${env.GIT_BRANCH}"
                }
            }
        }
    }

    post {
        success {
            // Add any post-build actions as necessary
            echo "PR exitoso y aprobado!"
        }
    }
}
