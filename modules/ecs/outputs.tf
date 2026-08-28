output "alb_url" {
  value       = "http://${aws_lb.app.dns_name}"
  description = "URL publique de l'application ECS"
}
output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
