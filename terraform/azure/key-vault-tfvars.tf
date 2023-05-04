module "azurerm_key_vault_tfvars" {
  source = "github.com/DFE-Digital/terraform-azurerm-key-vault-tfvars?ref=v0.1.3"

  count = local.enable_key_vault_tfvars ? 1 : 0

  environment               = local.environment
  project_name              = local.project_name
  azure_location            = azurerm_resource_group.default.location
  existing_resource_group   = azurerm_resource_group.default.name
  key_vault_access_users    = local.key_vault_access_users
  key_vault_access_ipv4     = local.key_vault_access_ipv4
  tfvars_filename           = local.key_vault_tfvars_filename
  enable_diagnostic_setting = local.key_vault_enable_diagnostic_setting
  tags                      = local.tags

  depends_on = [azurerm_resource_group.default]
}
