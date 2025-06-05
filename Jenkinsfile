pipeline {
    agent {
        kubernetes {
            yamlFile 'clusters/prod/apps/chatbot/docker-agent.yaml'
            defaultContainer 'docker'
        }
    }

    environment {
        REPO_URL = 'https://github.com/su-mangale/fluxcd.git'
        SPARSE_PATH = 'clusters/prod/apps/chatbot'
        IMAGE_TAG = "2.4.${BUILD_ID}"
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'mangale/smart-ai'
        DOCKER_IMAGE_FULL = "${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}"
    }

    stages {
        stage('Prepare Workspace') {
            steps {
                container('jnlp') {
                    sh '''
                        mkdir -p /home/jenkins/agent/workspace
                        chmod -R 777 /home/jenkins/agent/workspace
                    '''
                }
            }
        }

        stage('Sparse Checkout') {
            steps {
                container('docker') {
                    sh '''
                        git init
                        git config --global --add safe.directory `pwd`
                        git remote remove origin || true
                        git remote add origin ${REPO_URL}
                        git sparse-checkout init --cone
                        git sparse-checkout set ${SPARSE_PATH}
                        git pull origin main
                    '''
                }
            }
        }


        stage('Build Docker Image') {
            steps {
                container('docker') {
                    dir("${env.SPARSE_PATH}") {
                        sh '''
                            echo "Building image: ${DOCKER_IMAGE_FULL}"
                            docker build -t ${DOCKER_IMAGE_FULL} .
                        '''
                    }
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