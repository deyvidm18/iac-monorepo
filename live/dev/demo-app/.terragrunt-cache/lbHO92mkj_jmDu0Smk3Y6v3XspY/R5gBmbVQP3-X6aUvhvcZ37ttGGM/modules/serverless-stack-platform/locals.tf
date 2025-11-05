locals {
  labels = {
    environment = var.environment_label
    application = var.application_label
    team        = var.team_label
  }
  load_balancer_domain = var.load_balancer_domain == "" ? "${var.name}.${var.base_domain}" : var.load_balancer_domain
}