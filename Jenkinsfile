def registry = 'https://trial198pnt.jfrog.io'
def imageName = 'trial198pnt.jfrog.io/tarun-docker-local/tarun-docker'
def version   = '2.1.4'

pipeline {
    agent {
        node {
            label 'maven'
        }
    }
environment {
    PATH = "/opt/apache-maven-3.9.14/bin:$PATH"
}
    stages {
        stage("build"){
            steps {
                sh 'mvn clean deploy'
            }
        }

    stage('SonarQube analysis') {  
    environment {
        scannerHome = tool 'devops-sonar-scanner'
    }  
    steps{
    withSonarQubeEnv('devops-sonarqube-server') { // If you have configured more than one
            sh "${scannerHome}/bin/sonar-scanner"
        }
        }
    }

 /*   stage("Quality Gate"){
        steps {
            script {
            timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
        def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
        if (qg.status != 'OK') {
            error "Pipeline aborted due to quality gate failure: ${qg.status}"
        }
    }
}
        }
    }
*/
        stage("Jar Publish") {
        steps {
            script {
                    echo '<--------------- Jar Publish Started --------------->'
                    def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"artifact-cred"
                    def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                    def uploadSpec = """{
                        "files": [
                            {
                            "pattern": "jarstaging/(*)",
                            "target": "maven-repo-libs-release-local/{1}",
                            "flat": "false",
                            "props" : "${properties}",
                            "exclusions": [ "*.sha1", "*.md5"]
                            }
                        ]
                    }"""
                    def buildInfo = server.upload(uploadSpec)
                    buildInfo.env.collect()
                    server.publishBuildInfo(buildInfo)
                    echo '<--------------- Jar Publish Ended --------------->'  
            
            }
        }   
    }   
    stage(" Docker Build ") {
        steps {
            script {
                echo '<--------------- Docker Build Started --------------->'
                app = docker.build(imageName+":"+version)
                echo '<--------------- Docker Build Ends --------------->'
        }
    }
    }

            stage (" Docker Publish "){
        steps {
            script {
                echo '<--------------- Docker Publish Started --------------->'  
                docker.withRegistry(registry, 'artifact-cred'){
                    app.push()
                }    
                echo '<--------------- Docker Publish Endad --------------->'  
            }
        }
    }  
    
    stage  ("Kubernetes"){
        steps {
            script {
                sh './deploy.sh'
            }
        }
    }
}
}
