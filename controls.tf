// controls
resource "azurerm_resource_group" "control" {
  name                  = var.control_resource_name
  location              = var.main_region
  tags                  = local.control_tags
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length           = 8
}

resource "azurerm_log_analytics_workspace" "control" {
  name                  = "${var.control_resource_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location              = azurerm_resource_group.control.location
  resource_group_name   = azurerm_resource_group.control.name
  sku                   = var.log_analytics_workspace_sku
  tags                  = local.control_tags
}

resource "azurerm_log_analytics_solution" "control" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.control.location
  resource_group_name   = azurerm_resource_group.control.name
  workspace_resource_id = azurerm_log_analytics_workspace.control.id
  workspace_name        = azurerm_log_analytics_workspace.control.name
  plan {
    publisher           = "Microsoft"
    product             = "OMSGallery/ContainerInsights"
  }
}
