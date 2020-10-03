resource "azurerm_resource_group" "shared" {
  name                = var.shared_resource_name
  location            = var.main_region
  tags                = local.shared_tags
}

resource "azurerm_container_registry" "acr" {
  name                = var.shared_resource_name
  resource_group_name = azurerm_resource_group.shared.name
  location            = azurerm_resource_group.shared.location
  sku                 = "Premium"
  admin_enabled       = true
  tags                = local.shared_tags
}
