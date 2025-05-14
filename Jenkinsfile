pipeline {
  agent { label 'jenkinsnode' }
  stages {
    stage('Build') {
      steps {
       sh 'docker build -t 2058615mangal/ai-bot:$BUILD_NUMBER .'
      }
    }
    stage('Test') {
      steps {
       echo "Run tests" 
      }
    }
  }
}
