pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub_credentials'
        EKS_CLUSTER_NAME = 'foxops'
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-repo/notes-app.git'
            }
        }
        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh 'docker build -t your-dockerhub-username/frontend .'
                }
            }
        }
        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh 'docker build -t your-dockerhub-username/backend .'
                }
            }
        }
        stage('Push Images') {
            steps {
                withDockerRegistry(credentialsId: "${env.DOCKER_CREDENTIALS_ID}") {
                    sh 'docker push your-dockerhub-username/frontend'
                    sh 'docker push your-dockerhub-username/backend'
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig', contextName: "${env.EKS_CLUSTER_NAME}"]) {
                    sh 'kubectl apply -f k8s/frontend-deployment.yaml'
                    sh 'kubectl apply -f k8s/backend-deployment.yaml'
                    sh 'kubectl apply -f k8s/mongo-deployment.yaml'
                }
            }
        }
    }
}
