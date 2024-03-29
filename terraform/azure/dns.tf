data "azurerm_dns_zone" "get_help_buying_for_schools__service__gov__uk" {
  name                = "get-help-buying-for-schools.service.gov.uk"
  resource_group_name = local.parent_dns_zone_resource_group_name
  provider            = azurerm.prod
}

resource "azurerm_dns_ns_record" "parent_child_dns_zone_connection" {
  count = local.connect_dns_to_parent_zone ? 1 : 0

  name                = local.parent_dns_zone_record_name
  zone_name           = data.azurerm_dns_zone.get_help_buying_for_schools__service__gov__uk.name
  resource_group_name = data.azurerm_dns_zone.get_help_buying_for_schools__service__gov__uk.resource_group_name
  ttl                 = 300
  records             = module.azure_container_apps_hosting.azurerm_dns_zone_name_servers
  provider            = azurerm.prod
  lifecycle {
    ignore_changes = [tags]
  }
}
