pipeline {
  agent any

  environment {
    // Terraform tournera dans le workspace du job
    TF_IN_AUTOMATION = "true"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate') {
      steps {
        sh 'terraform init -input=false'
        sh 'terraform fmt -check'
        sh 'terraform validate'
      }
    }

    stage('Plan') {
      steps {
        // plan des DEUX cibles (ECS + K8s) en un seul plan
        sh 'terraform plan -input=false -out=tfplan'
      }
    }

    stage('Approve') {
      steps {
        input message: 'Appliquer le deploiement ECS + Kubernetes ?'
      }
    }

    stage('Apply') {
      steps {
        // idempotent : n'applique que les differences du plan
        sh 'terraform apply -input=false tfplan'
      }
    }
  }

  post {
    success { echo 'Deploiement ECS + Kubernetes termine.' }
    failure { echo 'Echec du pipeline - voir les logs.' }
  }
}
