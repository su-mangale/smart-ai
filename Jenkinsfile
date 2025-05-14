pipeline {
  agent { label 'jenkinsnode' }
  environment {
    IMAGE_NAME = "2058615mangal/ai-bot"
    IMAGE_TAG = "${BUILD_ID}"
  }
  stages {
    stage('Build') {
      steps {
       sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
      }
    }
    stage('Test') {
      steps {
       echo "Run tests" 
      }
    }
  }
}
