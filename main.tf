provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

module "k8s" {
  source = "./modules/k8s"
}

module "ecs" {
  source       = "./modules/ecs"
  lab_role_arn = var.lab_role_arn
}
