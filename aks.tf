resource "azurerm_resource_group" "aks" {
  name                  = var.aks_resource_name
  location              = var.main_region
  tags                  = local.infra_tags
}
