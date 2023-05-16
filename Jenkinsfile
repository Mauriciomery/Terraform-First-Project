pipeline {
    agent any

    stages {
        stage('Terraform Verification') {
            steps {
                sh 'ls'
                echo 'Aqui estamos'
                sh 'cat jenkinsfile'
                sh 'terraform init'
                //sh 'terraform validate'
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
