output "namespace" {
  value = kubernetes_namespace.boutique.metadata[0].name
}
output "service_nodeport" {
  value = kubernetes_service.web.spec[0].port[0].node_port
}
