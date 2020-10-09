resource "azurerm_resource_group" "k8s" {
  name                       = var.aks_resource_name
  location                   = var.main_region
  tags                       = local.infra_tags
}

data "azurerm_log_analytics_workspace" "control" {
  name                       = var.azurerm_log_analytics_workspace_name
  resource_group_name        = var.azurerm_log_analytics_workspace_resource_group
}

resource "azuread_application" "aks-aad-srv" {
  name                       = "${var.aks_resource_name}srv"
  homepage                   = "https://${var.aks_resource_name}srv"
  identifier_uris            = ["https://${var.aks_resource_name}srv"]
  reply_urls                 = ["https://${var.aks_resource_name}srv"]
  type                       = "webapp/api"
  group_membership_claims    = "All"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
  required_resource_access {
    resource_app_id          = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id                     = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type                   = "Role"
    }
    resource_access {
      id                     = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type                   = "Scope"
    }
    resource_access {
      id                     = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type                   = "Scope"
    }
  }
  required_resource_access {
    resource_app_id          = "00000002-0000-0000-c000-000000000000"
    resource_access {
      id                     = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type                   = "Scope"
    }
  }
}
resource "azuread_service_principal" "aks-aad-srv" {
  application_id             = azuread_application.aks-aad-srv.application_id
}
resource "random_password" "aks-aad-srv" {
  length                     = 32
  special                    = true
}
resource "azuread_application_password" "aks-aad-srv" {
  application_object_id      = azuread_application.aks-aad-srv.object_id
  value                      = random_password.aks-aad-srv.result
  end_date                   = "2025-10-07T07:20:50.52Z"
}
resource "azuread_application" "aks-aad-client" {
  name                       = "${var.aks_resource_name}client"
  homepage                   = "https://${var.aks_resource_name}client"
  reply_urls                 = ["https://${var.aks_resource_name}client"]
  type                       = "native"
  required_resource_access {
    resource_app_id          = azuread_application.aks-aad-srv.application_id
    resource_access {
      id                     = azuread_application.aks-aad-srv.oauth2_permissions.*.id[0]
      type                   = "Scope"
    }
  }
}
resource "azuread_service_principal" "aks-aad-client" {
  application_id             = azuread_application.aks-aad-client.application_id
}
resource "azuread_group" "aks-aad-clusteradmins" {
  name                       = "${var.aks_resource_name}_clusteradmin"
}
resource "azuread_application" "aks_sp" {
  name                       = var.aks_resource_name
  homepage                   = "https://${var.aks_resource_name}"
  identifier_uris            = ["https://${var.aks_resource_name}"]
  reply_urls                 = ["https://${var.aks_resource_name}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
}
resource "azuread_service_principal" "aks_sp" {
  application_id             = azuread_application.aks_sp.application_id
}
resource "random_password" "aks_sp_pwd" {
  length                     = 32
  special                    = true
}
resource "azuread_service_principal_password" "aks_sp_pwd" {
  service_principal_id       = azuread_service_principal.aks_sp.id
  value                      = random_password.aks_sp_pwd.result
  end_date                   = "2025-10-07T07:20:50.52Z"
}
resource "azurerm_role_assignment" "aks_sp_role_assignment" {
  scope                      = data.azurerm_subscription.current.id
  role_definition_name       = "Contributor"
  principal_id               = azuread_service_principal.aks_sp.id

  depends_on = [
    azuread_service_principal_password.aks_sp_pwd
  ]
}
resource "null_resource" "delay_before_consent" {
  provisioner "local-exec" {
    command                  = "sleep 60"
  }
  depends_on = [
    azuread_service_principal.aks-aad-srv,
    azuread_service_principal.aks-aad-client
  ]
}
resource "null_resource" "grant_srv_admin_constent" {
  provisioner "local-exec" {
    command                  = "az ad app permission admin-consent --id ${azuread_application.aks-aad-srv.application_id}"
  }
  depends_on                 = [
    null_resource.delay_before_consent
  ]
}
resource "null_resource" "grant_client_admin_constent" {
  provisioner "local-exec" {
    command                  = "az ad app permission admin-consent --id ${azuread_application.aks-aad-client.application_id}"
  }
  depends_on                 = [
    null_resource.delay_before_consent
  ]
}
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command                  = "sleep 60"
  }
  depends_on                 = [
    null_resource.grant_srv_admin_constent,
    null_resource.grant_client_admin_constent
  ]
}
resource "azurerm_kubernetes_cluster" "aks" {
  name                       = var.aks_resource_name
  location                   = var.main_region
  resource_group_name        = azurerm_resource_group.k8s.name
  dns_prefix                 = var.aks_resource_name
  tags                       = local.infra_tags
  default_node_pool {
    name                     = "default"
    type                     = "VirtualMachineScaleSets"
    node_count               = 2
    vm_size                  = "Standard_B2s"
    os_disk_size_gb          = 30
    max_pods                 = 50
  }
  service_principal {
    client_id                = azuread_application.aks_sp.application_id
    client_secret            = random_password.aks_sp_pwd.result
  }
  addon_profile {
    oms_agent {
      enabled                = true
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.control.id
    }
  }
  role_based_access_control {
    azure_active_directory {
      client_app_id          = azuread_application.aks-aad-client.application_id
      server_app_id          = azuread_application.aks-aad-srv.application_id
      server_app_secret      = random_password.aks-aad-srv.result
      tenant_id              = data.azurerm_subscription.current.tenant_id
    }
    enabled                  = true
  }
  depends_on                 = [
    azurerm_role_assignment.aks_sp_role_assignment,
    azuread_service_principal_password.aks_sp_pwd
  ]
}
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = data.azurerm_log_analytics_workspace.control.name
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.control.id

  log {
    category                 = "kube-apiserver"
    enabled                  = true
    retention_policy {
      enabled                = false
      days                   = 30
    }
  }
  log {
    category                 = "kube-audit"
    enabled                  = true
    retention_policy {
      enabled                = false
      days                   = 30
    }
  }
  log {
    category                 = "kube-audit-admin"
    enabled                  = true
    retention_policy {
      enabled                = false
      days                   = 30
    }
  }
  log {
    category                 = "kube-controller-manager"
    enabled                  = true
    retention_policy {
      enabled                = false
      days                   = 30
    }
  }
  log {
    category                 = "kube-scheduler"
    enabled                  = true
    retention_policy {
      enabled                = false
      days                   = 30
    }
  }
  log {
    category                 = "cluster-autoscaler"
    enabled                  = true
    retention_policy {
      enabled                = false
      days                   = 30
    }
  }
  log {
    category                 = "guard"
    enabled                  = true
    retention_policy {
      enabled                = false
      days                   = 30
    }
  }
  metric {
    category                 = "AllMetrics"
    retention_policy {
      enabled                = false
      days                   = 30
    }
  }
  depends_on                 = [
    azurerm_kubernetes_cluster.aks
  ]
}
data "azurerm_client_config" "current" {}

resource "random_id" "key_vault_name_suffix" {
  byte_length           = 4
}
resource "azurerm_key_vault" "aks" {
  name                       = "${var.aks_resource_name}-${random_id.key_vault_name_suffix.dec}"
  location                   = azurerm_kubernetes_cluster.aks.location
  resource_group_name        = azurerm_resource_group.k8s.name
  enabled_for_disk_encryption = true
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled        = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name = "standard"

  access_policy {
    tenant_id                = data.azurerm_client_config.current.tenant_id
    object_id                = data.azurerm_client_config.current.object_id

    key_permissions          = ["get"]
    secret_permissions       = ["get"]
    storage_permissions      = ["get"]
  }

  network_acls {
    default_action           = "Deny"
    bypass                   = "AzureServices"
  }
  tags                       = local.infra_tags
}