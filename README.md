# Orchestration automatisée — ECS + Kubernetes

D�ploiement d'une même application sur **Amazon ECS (Fargate)** et **Kubernetes (Minikube)**,
industrialisé via une chaîne unique **Terraform + Jenkins**.

## Structure du dépôt

```
.modules/ecs/    ECR, cluster Fargate, task definition (LabRole), ALB, security groups, service ECS
.modules/k8s/    namespace, ConfigMap, Deployment (3 réplicas + sondes), Service, Ingress, HPA
.kyverno/       politique de sécurité (interdiction du tag latest)
.main.tf / variables.tf / versions.tf   configuration racine (providers aws + kubernetes)
.Jenkinsfile     pipeline validate -> plan -> approbation -> apply
```

## Prérequis

- Terraform >= 1.5, AWS CLI (session AWS Academy), Docker, Minikube, kubectl, Helm, Jenkins
- Cluster Minikube démarré avec le CNI Calico :
  ```
  minikube start --driver=docker --cni=calico
  ```
- Addons : `minikube addons enable ingress` et `minikube addons enable metrics-server`
- Kyverno installé : `helm install kyverno kyverno/kyverno -n kyverno --create-namespace`

## Secrets (jamais versionnés)

L'ARN du LabRole est fourni via `terraform.tfvars` (ignoré par Git) ou la variable
d'environnement `TF_VAR_lab_role_arn`. Côté Jenkins, il est stocké en credential.

## D�ploiement

### En local

```bash
terraform init
terraform plan
terraform apply
```

### Via Jenkins

Le job `orchestration-ecs-k8s` exécute le pipeline (validate -> plan -> approbation -> apply)
et pilote les deux cibles. Le pipeline est idempotent : une seconde exécution ne modifie rien.

## Vérification

- ECS  : `http://<dns-alb>` (HTTP 200)
- K8s  : `http://<ip-minikube>:<nodeport>` ou `http://boutique.local/` (HTTP 200)

## Sécurité

- Moindre privilège : LabRole côté ECS, security groups restreints, Kyverno côté K8s
- Aucun secret en clair dans le dépôt (`.gitignore` couvre tfstate, tfvars, credentials)
- Images taguées (jamais `latest`)
