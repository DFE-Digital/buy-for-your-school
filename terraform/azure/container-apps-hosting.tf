module "azure_container_apps_hosting" {
  # source = "github.com/DFE-Digital/terraform-azurerm-container-apps-hosting?ref=6f527070de93876ca28daff70fd7ed16600cc9ca"
  source = "github.com/ryantk/terraform-azurerm-container-apps-hosting?ref=ryans-changes"

  environment             = local.environment
  project_name            = local.project_name
  azure_location          = azurerm_resource_group.default.location
  existing_resource_group = azurerm_resource_group.default.name
  tags                    = local.tags

  custom_container_apps = local.custom_container_apps

  enable_container_registry = local.enable_container_registry
  registry_password         = local.docker_registry_password
  registry_server           = local.docker_image_registry
  image_name                = local.docker_image
  image_tag                 = local.docker_image_tag
  container_port            = local.container_port
  container_command         = local.container_command

  container_min_replicas                        = local.container_min_replicas
  container_max_replicas                        = local.container_max_replicas
  container_scale_rule_concurrent_request_count = local.container_scale_rule_concurrent_request_count

  enable_worker_container       = local.enable_worker_container
  worker_container_command      = local.worker_container_command
  worker_container_min_replicas = local.worker_container_min_replicas
  worker_container_max_replicas = local.worker_container_max_replicas

  enable_container_health_probe          = local.enable_container_health_probe
  container_health_probe_interval        = local.container_health_probe_interval
  container_health_probe_protocol        = local.container_health_probe_protocol
  container_secret_environment_variables = local.application_env

  enable_monitoring                 = local.enable_monitoring
  monitor_email_receivers           = local.monitoring_email_receivers
  monitor_endpoint_healthcheck      = local.monitoring_endpoint_healthcheck
  monitor_enable_slack_webhook      = local.monitoring_enable_slack_webhook
  monitor_slack_webhook_receiver    = local.monitoring_slack_webhook_receiver
  monitor_slack_channel             = local.monitoring_slack_channel
  alarm_cpu_threshold_percentage    = local.monitoring_alarm_cpu_threshold_percentage
  alarm_memory_threshold_percentage = local.monitoring_alarm_memory_threshold_percentage
  alarm_latency_threshold_ms        = local.monitoring_alarm_latency_threshold_ms

  enable_dns_zone              = local.enable_dns_zone
  dns_zone_domain_name         = local.dns_zone_domain_name
  cdn_frontdoor_custom_domains = local.cdn_frontdoor_custom_domains

  enable_cdn_frontdoor                        = local.enable_cdn_frontdoor
  restrict_container_apps_to_cdn_inbound_only = local.restrict_container_apps_to_cdn_inbound_only
  enable_cdn_frontdoor_health_probe           = local.enable_cdn_frontdoor_health_probe
  cdn_frontdoor_health_probe_interval         = local.cdn_frontdoor_health_probe_interval
  cdn_frontdoor_health_probe_path             = local.cdn_frontdoor_health_probe_path
  cdn_frontdoor_health_probe_request_type     = local.cdn_frontdoor_health_probe_request_type
  cdn_frontdoor_origin_host_header_override   = local.cdn_frontdoor_origin_host_header_override

  enable_redis_cache                   = local.enable_redis_cache
  redis_cache_version                  = local.redis_cache_version
  redis_cache_family                   = local.redis_cache_family
  redis_cache_sku                      = local.redis_cache_sku
  redis_cache_capacity                 = local.redis_cache_capacity
  redis_cache_patch_schedule_day       = local.redis_cache_patch_schedule_day
  redis_cache_patch_schedule_hour      = local.redis_cache_patch_schedule_hour
  redis_cache_firewall_ipv4_allow_list = local.redis_cache_firewall_ipv4_allow_list

  enable_container_app_blob_storage                = local.enable_container_app_blob_storage
  container_app_blob_storage_public_access_enabled = local.container_app_blob_storage_public_access_enabled
  container_app_blob_storage_ipv4_allow_list       = local.container_app_blob_storage_ipv4_allow_list

  enable_postgresql_database             = local.enable_postgresql_database
  postgresql_server_version              = local.postgresql_server_version
  postgresql_sku_name                    = local.postgresql_sku_name
  postgresql_administrator_login         = local.postgresql_administrator_login
  postgresql_administrator_password      = local.postgresql_administrator_password
  postgresql_enabled_extensions          = local.postgresql_enabled_extensions
  postgresql_network_connectivity_method = local.postgresql_network_connectivity_method
  postgresql_firewall_ipv4_allow         = local.postgresql_firewall_ipv4_allow

  depends_on = [azurerm_resource_group.default]
}

