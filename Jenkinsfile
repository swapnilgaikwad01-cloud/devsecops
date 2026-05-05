pipeline {
    agent any

    tools {
        maven 'maven3'
       //jdk 'jdk21'
    }

    stages {

       /* stage('Checkout') {
            steps {
                git 'https://github.com/swapnilgaikwad01-cloud/devsecops.git'
                echo "Repo cloend successfully"
            }
        } */

        stage('Secret Scan') {
            steps {
                sh 'gitleaks detect --source .'
                echo "Secret detected in the code"
            }
        }

        stage('Code Quality - SonarQube') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
            }
        }

        stage('Image Scan - Trivy') {
            steps {
                sh '''
                trivy image \
                --exit-code 1 \
                --severity HIGH,CRITICAL \
                $IMAGE_NAME:$BUILD_NUMBER
                '''
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                    echo $PASS | docker login -u $USER --password-stdin
                    docker push $IMAGE_NAME:$BUILD_NUMBER
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'dependency-check-report/*', allowEmptyArchive: true
        }
    }
}
