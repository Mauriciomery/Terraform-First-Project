pipeline {
    agent any

    stages {
        stage('Terraform Verification') {
            steps {
                sh 'ls'
                echo 'Aqui estamos'
                sh 'cat Jenkinsfile'
                //sh 'terraform init'
                //sh 'terraform validate'
            }
        }
        stage('Verify Tag') {
            steps {
                sh 'grep -q "responsible = "mauricio.merya"" main.tf'
                echo 'Llegamos hasta validar tag' 
            }
        }
        stage('Handle Result') {
            steps {
                 script {
                    if (sh(returnStatus: true, script: 'grep -q "responsible = "mauricio.merya"" main.tf') == 0) {
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
                echo "Aqui se ejecuta una verificación extra"
            }
        }
        stage('Accept and Merge Pull Request') {
            steps {
                script {
                    def gitUrl = env.GIT_URL.replace("https://", "https://$env.GITHUB_TOKEN@")
                    sh "git config --global user.email 'mauricio.mery0527@gmail.com'"
                    sh "git config --global user.name 'Mauriciomery'"
                    sh "git clone $gitUrl ."
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
