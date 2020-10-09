provider "azurerm" {
  version         = "~> 2.30.0"
//  subscription_id = var.subscription_id
//  client_id       = var.client_id
//  client_secret   = var.client_secret
//  tenant_id       = var.tenant_id
  features {}
}
provider "azuread" {
  version = "~> 1.0.0"
}

provider "random"  {
  version = "~> 2.2"
}

provider "http"    {
  version = "~> 1.2"
}

provider "null"    {
  version = "~> 2.1"
}
