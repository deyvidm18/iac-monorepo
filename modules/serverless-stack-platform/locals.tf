locals {
  labels = {
    environment = var.environment_label
    application = var.application_label
    team        = var.team_label
  }
  load_balancer_domain = var.load_balancer_domain == "" ? "${var.name}.${var.base_domain}" : var.load_balancer_domain
  iam_bindings = flatten([
    for role in var.iam_profiles.viewer : [
      for member in var.viewer_members : {
        role   = role
        member = member
      }
    ]
    ],
    [
      for role in var.iam_profiles.developer : [
        for member in var.developer_members : {
          role   = role
          member = member
        }
      ]
    ],
    [
      for role in var.iam_profiles.web_user : [
        for member in var.web_user_members : {
          role   = role
          member = member
        }
      ]
    ]
  )
}