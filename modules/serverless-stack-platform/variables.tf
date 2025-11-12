//-------------------------------------------------
// Core Configuration
//-------------------------------------------------
variable "project_id" {
  type        = string
  description = "The GCP project ID to deploy all resources into."
}

variable "region" {
  type        = string
  description = "The primary GCP region for regional resources."
}

variable "environment" {
  type        = string
  description = "The deployment environment name (e.g., dev, prod)."
}

variable "name" {
  type        = string
  description = "The base name for all resources, derived from the application's directory name."
}

//-------------------------------------------------
// Service Enablement Flags (Controls what gets created)
//-------------------------------------------------
variable "enable_cloud_run_frontend" {
  type    = bool
  default = true
}
variable "enable_cloud_run_backend" {
  type    = bool
  default = true
}
variable "enable_cloud_sql" {
  type    = bool
  default = true
}
variable "enable_firestore" {
  type    = bool
  default = true
}
variable "enable_memorystore" {
  type    = bool
  default = true
}
variable "enable_pubsub_topics" {
  type    = bool
  default = true
}
variable "enable_load_balancer" {
  type    = bool
  default = true
}
variable "enable_iap" {
  type        = bool
  default     = false
  description = "Controls creation of IAP and its binding to the LB."
}

//-------------------------------------------------
// T-Shirt Sizing Configuration
//-------------------------------------------------
variable "sizing" {
  type        = string
  description = "Defines the T-shirt size for the environment (small, medium, large)."
  validation {
    condition     = contains(["small", "medium", "large"], var.sizing)
    error_message = "Valid values for sizing are: small, medium, large."
  }
}

variable "t_shirt_sizes" {
  type = map(object({
    cloud_run_cpu           = number
    cloud_run_memory        = string
    cloud_run_min_instances = number
    cloud_run_max_instances = number
    cloudsql_tier           = string
    cloudsql_ha             = bool
    memorystore_size_gb     = number
    memorystore_tier        = string // BASIC or STANDARD_HA
  }))
}

//-------------------------------------------------
// Network Configuration
//-------------------------------------------------
variable "network_project_id" {
  type        = string
  description = "The project ID of the shared VPC host project."
}

variable "vpc_name" {
  type        = string
  description = "The name of the shared VPC network."
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet to use for Direct VPC Egress."
}

variable "proxy_only_subnet_name" {
  type        = string
  description = "The name of the proxy-only subnet for the internal load balancer."
}

variable "zone" {
  type        = string
  description = "The primary GCP zone for zonal resources."
  default     = "us-central1-a"
}

variable "private_ip_allocation_name" {
  type        = string
  description = "The name of the private IP allocation for the Service Networking connection."
}

//-------------------------------------------------
// Service-Specific Overrides & Inputs
//-------------------------------------------------
variable "frontend_container_image" {
  type    = string
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "backend_container_image" {
  type    = string
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "load_balancer_domain" {
  type        = string
  description = "The domain name for the managed SSL certificate (e.g., myapp.example.com)."
  default     = ""
}

variable "iap_support_email" {
  type        = string
  description = "An email of a user in the project to act as support contact for the OAuth brand."
}

variable "iap_members" {
  type        = list(string)
  description = "List of members to grant IAP access (e.g., user:email@example.com)."
  default     = []
}

variable "environment_label" {
  type        = string
  description = "The environment label."
}

variable "application_label" {
  type        = string
  description = "The application label."
}

variable "team_label" {
  type        = string
  description = "The team label."
}

variable "force_destroy" {
  type        = bool
  description = "If set to true, it will disable deletion protection on resources."
  default     = false
}

variable "dns_project_id" {
  type        = string
  description = "The project ID of the central DNS project."
  default     = ""
}

variable "public_dns_zone_name" {
  type        = string
  description = "The name of the public managed DNS zone."
  default     = ""
}

variable "private_dns_zone_name" {
  type        = string
  description = "The name of the private managed DNS zone."
  default     = ""
}

variable "base_domain" {
  type        = string
  description = "The base domain for the application."
  default     = ""
}

variable "frontend_load_balancer_type" {
  type        = string
  description = "The type of load balancer for the frontend. Can be EXTERNAL or INTERNAL."
  default     = "EXTERNAL"
  validation {
    condition     = contains(["EXTERNAL", "INTERNAL"], var.frontend_load_balancer_type)
    error_message = "Valid values for frontend_load_balancer_type are: EXTERNAL, INTERNAL."
  }
}

variable "internal_load_balancer_domain" {
  type        = string
  description = "The domain for the internal load balancer's SSL certificate."
  default     = ""
}

variable "disable_default_url" {
  type        = bool
  description = "If set to true, it will disable the default URL of the Cloud Run services."
  default     = true
}

variable "frontend_vpc_egress" {
  type        = string
  description = "The VPC egress settings for the frontend Cloud Run service."
  default     = "ALL_TRAFFIC"
}

variable "backend_vpc_egress" {

  type = string

  description = "The VPC egress settings for the backend Cloud Run service."

  default = "ALL_TRAFFIC"

}



variable "web_user_members" {



  description = "List of members to grant the 'web_user' profile roles (e.g., group:my-group@example.com)."



  type = list(string)



  default = []



}







variable "developer_members" {



  description = "List of members to grant the 'developer' profile roles (e.g., group:my-group@example.com)."



  type = list(string)



  default = []



}







variable "viewer_members" {



  description = "List of members to grant the 'viewer' profile roles (e.g., group:my-group@example.com)."



  type = list(string)



  default = []



}







variable "iam_profiles" {



  description = "A map of IAM profiles (viewer, developer, user) to a list of roles."



  type = map(list(string))



}




