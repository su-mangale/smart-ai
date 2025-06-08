pipeline {
    agent {
        kubernetes {
            yamlFile './docker-agent.yaml'
            defaultContainer 'docker'
        }
    }

    environment {
        REPO_URL = 'https://github.com/su-mangale/samart-ai.git'
        IMAGE_TAG = "2.4.${BUILD_ID}"
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'mangale/smart-ai'
        DOCKER_IMAGE_FULL = "${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                container('docker') {
                    git url: "${REPO_URL}", branch: 'main'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh '''
                        echo "Building image: ${DOCKER_IMAGE_FULL}"
                        docker build -t ${DOCKER_IMAGE_FULL} .
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker.io',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${DOCKER_IMAGE_FULL}
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            container('docker') {
                sh 'docker logout'
            }
            cleanWs()
        }
    }
}
