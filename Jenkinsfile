pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub_credentials'
        KUBECONFIG_CREDENTIAL_ID = 'kubeconfig'
        EKS_CLUSTER_NAME = 'rohan'
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Fox-R-fox/letsnameitlater.git'
            }
        }
        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh 'docker build -t foxe03/frontend .'
                }
            }
        }
        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh 'docker build -t foxe03/backend .'
                }
            }
        }
        stage('Push Images') {
            steps {
                withDockerRegistry([credentialsId: "${env.DOCKER_CREDENTIALS_ID}", url: 'https://index.docker.io/v1/']) {
                    sh 'docker push foxe03/frontend'
                    sh 'docker push foxe03/backend'
                }
            }
        }
        stage('List Files') {
            steps {
                sh 'ls -la k8s'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([string(credentialsId: "${env.KUBECONFIG_CREDENTIAL_ID}", variable: 'KUBECONFIG_BASE64')]) {
                    sh '''
                        echo "$KUBECONFIG_BASE64" | base64 --decode > /tmp/kubeconfig
                        export KUBECONFIG=/tmp/kubeconfig
                        kubectl apply -f k8s/mongo-pv.yaml
                        kubectl apply -f k8s/mongo-pvc.yaml
                        kubectl apply -f k8s/frontend-deployment.yaml
                        kubectl apply -f k8s/backend-deployment.yaml
                        kubectl apply -f k8s/mongo-deployment.yaml
                        kubectl apply -f k8s/backend-service.yaml
                    '''
                }
            }
        }
    }
}
