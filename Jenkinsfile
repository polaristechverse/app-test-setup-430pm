pipeline {
  agent{
    label 'Dev'
  }

  environment {
    IMAGE_NAME = "chaitanyamanikumar/javaslim"
    TAG = "${BUILD_NUMBER}"
    DOCKER_CREDS = "DockerHubAccess"
    TF_DIR = "/home/ubuntu/workspace/cd-infrasetup_develop" 
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }
    stage('Build Package'){
      steps{
        sh "mvn clean package -DskipTests > /dev/null 2>&1"
      }
    }
    stage('Build Docker Image') {
      steps {
        sh "docker build -t $IMAGE_NAME:$TAG ."
      }
    }

    stage('Docker Login') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: "${DOCKER_CREDS}",
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
        }
      }
    }

    stage('Push Image') {
      steps {
        sh "docker push $IMAGE_NAME:$TAG"
      }
    }
    stage('Check Infra (Terraform State)') {
      steps {
        script {
          dir("${TF_DIR}") {

            def status = sh(script: "terraform state list", returnStatus: true)

            if (status != 0) {
              echo "Infra not found → triggering infra pipeline..."

              build job: 'cd-infrasetup/develop',
                    wait: true,
                    parameters: [
                      string(name: 'REGION', value: 'ap-south-2'),
                      string(name: 'TERRAFORM_APPLY', value: 'yes'),
                      string(name: 'Ansible_Build', value: 'yes')
                      string(name: 'Pull_AMI', value: 'yes')
                    ]

              echo "Infra pipeline completed"
            } else {
              echo "Infra already exists (Terraform state present)"
            }
          }
        }
      }
    }
  }

  post {
    success {
      echo "Application deployed successfully!"
    }
    failure {
      echo "Pipeline failed!"
    }
  }
}