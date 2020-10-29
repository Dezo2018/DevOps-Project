
[![Build Status](http://ec2-52-59-242-134.eu-central-1.compute.amazonaws.com:8080/buildStatus/icon?job=CloudDevOps-ND-Capstone%2Fmaster)](http://ec2-52-59-242-134.eu-central-1.compute.amazonaws.com:8080/job/CloudDevOps-ND-Capstone/job/master/)

[![Build Status](http://ec2-52-59-242-134.eu-central-1.compute.amazonaws.com:8080/job/CloudDevOps-ND-Capstone/job/master/badge/icon?)](http://ec2-52-59-242-134.eu-central-1.compute.amazonaws.com:8080/job/CloudDevOps-ND-Capstone/job/master/)

[Github Repo of the project](https://github.com/bkocis/CloudDevOps-ND-Capstone)

#### Cloud DevOps Engineer Udacity Nanodegree Capstone Project
-----
# Deploying a Docker containerized Flask app on AWS Elastic Kubernetes Service 


## Description 

The project in this repository is about continuous deployment and integration of a simple flask app using Jenkins, Docker, and Kubernetes. The flask app is tested, containerized, and deployment from a Jenkins pipeline. In the final stage the docker image is deployed into a Kubernetes cluster and made accressible with a public URL. For the later part AWS's EKS (Elastic Kubernetes Service) was used to generate a cluster of 3 instances, load balancer, and all necessary settings. 

The generation and operation of the Kubernetes cluster takes place on the master instance, in this case on the same instance where Jenkins is installed. 

Jenkins automates and supports transparent building, testing, and deployment of the project, which are defined in the Jenkins pipeline `Jenkinsfile`. The stages and the steps are self explanatory, with the exception of the agents used. In this case I used multiple agents: 1. __agent any__ - default one, basically the environment of the instance, and a __Docker image agent__. This was necessary because I wanted to include a unit test of the python app inside the Jenkins pipeline. For this to be successful, the stage has to be able to run python and the required packages. This was done in order not to install everything on the main instance where Jenkins is installed on.

Further down the pipeline, the flask app is containerizes and uploaded to Docker-hub. The Docker image can be run separately via the `run_Docker.sh`, and can be made accessible using the public address of the instance.  

For orchestration, scalability and availability the Docker image containing the flask app can be deployed on a Kubernetes cluster. The deployment and running of the Docker image on the Kubernetes cluster requires the `deployment.yml` file for the configuration of the deployment type (in this case rolling) and service ports. At the end, the Docker image can be deployed on the cluster with a few commands encapsulated inside a single stage of the Jenkins pipeline: 

```bash
aws eks --region <REGION_NAME> update-kubeconfig --name <CLUSTER_NAME>
kubectl config use-context <ARN>  # something like: arn:aws:eks:eu-central-1:643313058211:cluster/<CLUSTER_NAME>
kubectl apply -f deployment.yml
kubectl set image deployments/<DOCKER_IMAGE_NAME> <DOCKER_IMAGE_NAME>=bkocis/<DOCKER_IMAGE_NAME>:latest
```

## Files

- Jenkinsfile
- Dockerfile
- run_Docker.sh
- requirement.txt
- app.py (flask web app)
- test.py (flask app unit test)
- deployment.yml

Other non-obligatory files, but good to have: 
- Makefile
- index.html (for testing html linting)


## Setup

#### AWS prerequisites

Some steps are required such as defining a new user, policy, save keypairs (.pem files for ssh access very important). Create a single ec2 instance (I chose a Ubuntu 18.04 AMI). 

#### Install Jenkins, Docker

```bash 
sudo apt-get update
sudo apt install -y default-jdk
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo apt install tidy
sudo apt-get install docker.io
sudo usermod -a -G docker ubuntu
sudo systemctl start docker
sudo usermod -a -G docker jenkins
```

#### Install aws-cli, kubectl, eksctl 

```bash
## aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip 
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
# aws configure # use non-root user

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile
```


## Workflow - DON'T FORGET TO DELETE CLUSTER

Before the deployment, start the Kubernetes cluster in EKS using:
`eksctl create cluster --name <CLUSTER_NAME> --version 1.16 --nodegroup-name standard-workers --node-type t2.medium --nodes 3 --nodes-min 1 --nodes-max 4 --node-ami auto --region <YOUR_PREFERED_REGION>`

With the cluster up and running (check `kubectl get nodes`, and `kubectr get deployments`), start the build in Jenkins. 

After the setup and successful builds don't forget to delete the eks cluster, which will terminate the ec2 instances of the workers in the cluster. `eksctl delete cluster --name=<CLUSTER_NAME>`.
In addition, at the end of the working day, it is a good idea to STOP the running instance (instance with Jenkins running) from the EC2 console. The next day START it again. Check the new public url address and the public IP's for the ssh access. When necessary modify the security group of the instance and change the ingress IP's.


## Screenshots 

__1. Running instances created by the EKS__

<img src="screenshots/instances.png" width=100%>



__2. AWS EKS kubernetes cluster is running and the Docker image is deployed__

<img src="screenshots/log-rollout.png" width=100%>



__3. Load balancer is created in the process as the endpoint address for the application__

<img src="screenshots/load-balancer.png" width=100%>



__4. The ingress rules might need to be configured, so that the port defined in the app could be available__

<img src="screenshots/security-group-inbound-rules.png" width=100%>



__5. The Jenkins pipeline used in the project, with the build history__

<img src="screenshots/jenkins-pipeline.png" width=100%>



__6. The deployed flask app__

<img src="screenshots/deployed-flask-app.png" width=100%>



__7. Unit test Jenkins stage for the Flask app shows a successful test__

<img src="screenshots/unit-testing-flask-app.png" width=100%>





