provider "azurerm" {
  version = "~> 2.3"
  features {}
}
//provider "azuread" {
//  version = "~> 0.8"
//}

provider "random"  {
  version = "~> 2.2"
}

provider "http"    {
  version = "~> 1.2"
}

provider "null"    {
  version = "~> 2.1"
}

terraform {
  backend "azurerm" {}
}
