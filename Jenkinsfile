pipeline {
    agent any

    tools {
        maven 'maven-3.9.14'
    }

    environment {
        SONAR_TOKEN = credentials('SONAR_AUTH_TOKEN')
    }

    stages {

        stage('Check Maven') {
            steps {
                sh 'mvn -v'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean verify'
            }
        }

        stage('SonarCloud Analysis') {
            steps {
                withSonarQubeEnv('devops-sonarqube-server') {
                    sh '''
                    mvn sonar:sonar \
                    -Dsonar.projectKey=sonarqube-key_twittertrend \
                    -Dsonar.organization=sonarqube-key \
                    -Dsonar.host.url=https://sonarcloud.io \
                    -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build & Sonar Analysis Successful"
        }
        failure {
            echo "❌ Pipeline Failed - Check logs"
        }
    }
}