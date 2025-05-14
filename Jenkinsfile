pipeline {
  agent { label 'jenkinsnode' }
  stages {
    stage('Build') {
      steps {
       sh 'sudo docker build -t 2058615mangal/ai-bot:latest .'
      }
    }
    stage('Test') {
      steps {
       echo "Run tests" 
      }
    }
  }
}
