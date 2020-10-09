// https://dev.to/cdennig/fully-automated-creation-of-an-aad-integrated-kubernetes-cluster-with-terraform-15cm
terraform {
  backend "azurerm" {}
}
data "azurerm_subscription"  "current" {}
