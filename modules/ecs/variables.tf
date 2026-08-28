variable "region" {
  type    = string
  default = "us-east-1"
}
variable "app_name" {
  type    = string
  default = "web-ipssi"
}
variable "image_tag" {
  type    = string
  default = "1.0.0"
}
variable "desired_count" {
  type    = number
  default = 2
}
variable "lab_role_arn" {
  type        = string
  description = "ARN du LabRole (execution role impose par AWS Academy)"
}
