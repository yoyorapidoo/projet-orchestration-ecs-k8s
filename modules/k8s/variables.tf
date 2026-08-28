variable "namespace" {
  type    = string
  default = "boutique"
}
variable "app_image" {
  type    = string
  default = "nginxdemos/hello:plain-text"  # image taguée, jamais latest
}
variable "replicas" {
  type    = number
  default = 3
}
