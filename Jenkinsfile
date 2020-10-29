pipeline {
    agent none
    stages {
        stage('Build start') {
            agent any
            steps {
                sh 'echo "Starting the project!"'
            }
        }
        stage('Lint HTML') {
            agent any
            steps {
                sh 'tidy -q -e *.html'
            }
        }
        stage('Lint flask python app') {
            agent { docker { image 'python:3.7.2' } }
            steps {
                withEnv(["HOME=${env.WORKSPACE}"]) {
                sh '''
                    python --version
                    pip install --upgrade --user pip
                    pip install -r requirements.txt
                    #apt-get install -y pylint
                    #pylint --disable=R,C,W1203,W1202 app.py || exit 0
                    python test.py
                '''
                }
            }
        }
	    stage('Security Scan') {
	        agent any
            steps {
                 aquaMicroscanner imageName: 'alpine:latest', notCompliesCmd: 'exit 1', onDisallowed: 'fail', outputFormat: 'html' 
            }
        }         
        stage('Upload to AWS') {
            agent any
            steps {
                withAWS(region:'us-west-2',credentials:'jenkins3-capstone_user_credentials') {
                s3Upload(pathStyleAccessEnabled: true, payloadSigningEnabled: true, file:'index.html', bucket:'clouddevops-nd-capstone')
                }
            }
        }
	    stage('Building docker image') {
	        agent any
	        steps {
			    sh 'docker build -t clouddevops-capstone .'			
	        }
	    }
	    stage('Push docker image to docker-hub') {
	        agent any
		    steps {
			    withDockerRegistry([url: "", credentialsId: "desjenkins"]){
			        sh "docker tag clouddevops-capstone desjenkins/clouddevops-capstone:latest"
			        sh "docker push desjenkins/clouddevops-capstone:latest"
			    }
            }
		}
        stage('Deploy to AWS EKS') {
            agent any
              steps{
                  withAWS(credentials: 'jenkins3-capstone_user_credentials', region: 'us-west-2') {
                    sh "aws eks --region us-west-2 update-kubeconfig --name capstone"
                    sh "kubectl config use-context arn:aws:eks:us-west-2:526037358249:cluster/capstone"
                    sh "kubectl get nodes"
                    sh "kubectl get deployments"
                    sh "kubectl apply -f deployment.yml"
                    sh "kubectl set image deployments/clouddevops-capstone clouddevops-capstone=desjenkins/clouddevops-capstone:latest"
                    sh "kubectl get deployments"
                    sh "kubectl rollout status deployments/clouddevops-capstone"
                    sh "kubectl get service/clouddevops-capstone"
                  }
              }
        }		
    }
}
