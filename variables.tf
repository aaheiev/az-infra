variable "azurerm_log_analytics_workspace_name" {
  default       = "control-16691188350723551381"
}
variable "azurerm_log_analytics_workspace_resource_group" {
  default       = "control"
}

variable main_region {
  default = "West Europe"
}

variable aks_resource_name {
  default = "demo"
}

locals {
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
