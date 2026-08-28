pipeline {
  agent any

  environment {
    TF_IN_AUTOMATION = "true"
    // lit la credential Jenkins "lab-role-arn" et l'expose a Terraform
    // (TF_VAR_xxx alimente automatiquement la variable Terraform "xxx")
    TF_VAR_lab_role_arn = credentials('lab-role-arn')
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Validate') {
      steps {
        sh 'terraform init -input=false'
        sh 'terraform fmt -check'
        sh 'terraform validate'
      }
    }

    stage('Plan') {
      steps { sh 'terraform plan -input=false -out=tfplan' }
    }

    stage('Approve') {
      steps { input message: 'Appliquer le deploiement ECS + Kubernetes ?' }
    }

    stage('Apply') {
      steps { sh 'terraform apply -input=false tfplan' }
    }
  }

  post {
    success { echo 'Deploiement ECS + Kubernetes termine.' }
    failure { echo 'Echec du pipeline - voir les logs.' }
  }
}
