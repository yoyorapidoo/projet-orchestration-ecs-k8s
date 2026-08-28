resource "kubernetes_namespace" "boutique" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "boutique" {
  metadata {
    name      = "boutique-config"
    namespace = kubernetes_namespace.boutique.metadata[0].name
  }
  data = {
    APP_NOM = "boutique_aicha"
    APP_ENV = "prod"
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.boutique.metadata[0].name
    labels    = { app = "web" }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = { app = "web" }
    }
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = var.app_image
          port {
            container_port = 80
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.boutique.metadata[0].name
            }
          }
          resources {
            requests = { cpu = "50m", memory = "32Mi" }
            limits   = { cpu = "150m", memory = "64Mi" }
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec[0].replicas]
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name      = "web-svc"
    namespace = kubernetes_namespace.boutique.metadata[0].name
  }
  spec {
    selector = { app = "web" }
    type     = "NodePort"
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "web" {
  metadata {
    name      = "boutique-ingress"
    namespace = kubernetes_namespace.boutique.metadata[0].name
  }
  spec {
    rule {
      host = "boutique.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.web.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "web" {
  metadata {
    name      = "web-hpa"
    namespace = kubernetes_namespace.boutique.metadata[0].name
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.web.metadata[0].name
    }
    min_replicas = 2
    max_replicas = 6
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}
