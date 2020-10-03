variable main_region {
  default = "West Europe"
}

variable control_resource_name {
  default = "a2-control"
}

variable aks_resource_name {
  default = "a2-demo"
}

locals {
  control_tags         = {
    tier               = "control"
    environment        = "control"
  }
  infra_tags           = {
    tier               = "app"
    environment        = "demo"
  }
}

//
//variable "agent_count" {
//  default = 3
//}
//
//variable "ssh_public_key" {
//  default = "~/.ssh/id_rsa.pub"
//}
//
//variable "dns_prefix" {
//  default = "k8s-demo"
//}
//
//variable cluster_name {
//  default = "k8s-demo"
//}
//
//variable resource_group_name {
//  default = "k8s-demo"
//}
//
//variable log_analytics_workspace_name {
//  default = "demo"
//}
//
//variable log_analytics_workspace_location {
//  default = "westeurope"
//}
//
//# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing

variable log_analytics_workspace_sku {
  default = "PerGB2018"
}
