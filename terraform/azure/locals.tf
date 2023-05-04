locals {
  environment             = var.environment
  project_name            = var.project_name
  resource_group          = var.resource_group
  resource_group_location = var.resource_group_location
  tags                    = var.tags

  custom_container_apps = var.custom_container_apps

  application_env                               = var.application_env
  enable_container_registry                     = var.enable_container_registry
  docker_registry_password                      = var.docker_registry_password
  docker_image_registry                         = var.docker_image_registry
  docker_image                                  = var.docker_image
  docker_image_tag                              = var.docker_image_tag
  container_port                                = var.container_port
  container_command                             = var.container_command
  container_cpu                                 = var.container_cpu
  container_memory                              = var.container_memory
  container_scale_rule_concurrent_request_count = var.container_scale_rule_concurrent_request_count
  container_min_replicas                        = var.container_min_replicas
  container_max_replicas                        = var.container_max_replicas

  enable_worker_container       = var.enable_worker_container
  worker_container_command      = var.worker_container_command
  worker_container_min_replicas = var.worker_container_min_replicas
  worker_container_max_replicas = var.worker_container_max_replicas

  enable_container_health_probe   = var.enable_container_health_probe
  container_health_probe_interval = var.container_health_probe_interval
  container_health_probe_protocol = var.container_health_probe_protocol

  enable_monitoring                            = var.enable_monitoring
  monitoring_email_receivers                   = var.monitoring_email_receivers
  monitoring_endpoint_healthcheck              = var.monitoring_endpoint_healthcheck
  monitoring_alarm_cpu_threshold_percentage    = var.monitoring_alarm_cpu_threshold_percentage
  monitoring_alarm_memory_threshold_percentage = var.monitoring_alarm_memory_threshold_percentage
  monitoring_alarm_latency_threshold_ms        = var.monitoring_alarm_latency_threshold_ms
  monitoring_enable_slack_webhook              = var.monitoring_enable_slack_webhook
  monitoring_slack_webhook_receiver            = var.monitoring_slack_webhook_receiver
  monitoring_slack_channel                     = var.monitoring_slack_channel

  enable_dns_zone                     = var.enable_dns_zone
  dns_zone_domain_name                = var.dns_zone_domain_name
  cdn_frontdoor_custom_domains        = var.cdn_frontdoor_custom_domains
  connect_dns_to_parent_zone          = var.connect_dns_to_parent_zone
  parent_dns_zone_record_name         = var.parent_dns_zone_record_name
  parent_dns_zone_resource_group_name = var.parent_dns_zone_resource_group_name

  enable_cdn_frontdoor                        = var.enable_cdn_frontdoor
  restrict_container_apps_to_cdn_inbound_only = var.restrict_container_apps_to_cdn_inbound_only
  enable_cdn_frontdoor_health_probe           = var.enable_cdn_frontdoor_health_probe
  cdn_frontdoor_health_probe_interval         = var.cdn_frontdoor_health_probe_interval
  cdn_frontdoor_health_probe_path             = var.cdn_frontdoor_health_probe_path
  cdn_frontdoor_health_probe_request_type     = var.cdn_frontdoor_health_probe_request_type
  cdn_frontdoor_origin_host_header_override   = var.cdn_frontdoor_origin_host_header_override

  enable_redis_cache                   = var.enable_redis_cache
  redis_cache_version                  = var.redis_cache_version
  redis_cache_family                   = var.redis_cache_family
  redis_cache_sku                      = var.redis_cache_sku
  redis_cache_capacity                 = var.redis_cache_capacity
  redis_cache_patch_schedule_day       = var.redis_cache_patch_schedule_day
  redis_cache_patch_schedule_hour      = var.redis_cache_patch_schedule_hour
  redis_cache_firewall_ipv4_allow_list = var.redis_cache_firewall_ipv4_allow_list

  enable_postgresql_database             = var.enable_postgresql_database
  postgresql_administrator_login         = var.postgresql_administrator_login
  postgresql_administrator_password      = var.postgresql_administrator_password
  postgresql_server_version              = var.postgresql_server_version
  postgresql_sku_name                    = var.postgresql_sku_name
  postgresql_network_connectivity_method = var.postgresql_network_connectivity_method
  postgresql_firewall_ipv4_allow         = var.postgresql_firewall_ipv4_allow
  postgresql_enabled_extensions          = var.postgresql_enabled_extensions

  enable_container_app_blob_storage                = var.enable_container_app_blob_storage
  container_app_blob_storage_public_access_enabled = var.container_app_blob_storage_public_access_enabled
  container_app_blob_storage_ipv4_allow_list       = var.container_app_blob_storage_ipv4_allow_list

  enable_key_vault_tfvars             = var.enable_key_vault_tfvars
  key_vault_access_users              = var.key_vault_access_users
  key_vault_access_ipv4               = var.key_vault_access_ipv4
  key_vault_tfvars_filename           = var.key_vault_tfvars_filename
  key_vault_enable_diagnostic_setting = var.key_vault_enable_diagnostic_setting
}
