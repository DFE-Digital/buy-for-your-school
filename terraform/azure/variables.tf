variable "container_app_name_override" {
  description = "Name of container to be used instead of default for environment purposes."
  type        = string
}

variable "production_subscription_id" {
  description = "ID of the production subscription, used for linking child and parent DNS zones."
  type        = string
}

variable "app_subscription_id" {
  description = "ID of the subscription to deploy the app into"
  type        = string
}

variable "environment" {
  description = "Environment name. Will be used along with `project_name` as a prefix for all resources."
  type        = string
}

variable "project_name" {
  description = "Project name. Will be used along with `environment` as a prefix for all resources."
  type        = string
}

variable "resource_group" {
  description = "Resource group name. Resources will be created within this resource group."
  type        = string
}

variable "resource_group_location" {
  description = "Resource group location. Location of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources and resource group"
  type        = map(string)
  default     = {}
}

# @note copy of azure rm custom container app 
variable "custom_container_apps" {
  description = "Custom container apps, by default deployed within the container app environment managed by this module."
  type = map(object({
    container_app_environment_id = optional(string, "")
    resource_group_name          = optional(string, "")
    revision_mode                = optional(string, "Single")
    container_port               = optional(number, 0)
    ingress = optional(object({
      external_enabled = optional(bool, true)
      target_port      = optional(number, null)
      traffic_weight = object({
        percentage = optional(number, 100)
      })
      cdn_frontdoor_custom_domain                = optional(string, "")
      cdn_frontdoor_origin_fqdn_override         = optional(string, "")
      cdn_frontdoor_origin_host_header_override  = optional(string, "")
      enable_cdn_frontdoor_health_probe          = optional(bool, false)
      cdn_frontdoor_health_probe_protocol        = optional(string, "")
      cdn_frontdoor_health_probe_interval        = optional(number, 120)
      cdn_frontdoor_health_probe_request_type    = optional(string, "")
      cdn_frontdoor_health_probe_path            = optional(string, "")
      cdn_frontdoor_forwarding_protocol_override = optional(string, "")
    }), null)
    identity = optional(list(object({
      type         = string
      identity_ids = list(string)
    })), [])
    secrets = optional(list(object({
      name  = string
      value = string
    })), [])
    registry = optional(object({
      server               = optional(string, "")
      username             = optional(string, "")
      password_secret_name = optional(string, "")
      identity             = optional(string, "")
    }), null),
    image   = string
    cpu     = number
    memory  = number
    command = list(string)
    liveness_probes = optional(list(object({
      interval_seconds = number
      transport        = string
      port             = number
      path             = optional(string, null)
    })), [])
    env = optional(list(object({
      name      = string
      value     = optional(string, null)
      secretRef = optional(string, null)
    })), [])
    min_replicas = number
    max_replicas = number
  }))
  default = {}
}

# @note original custom container defintion that appears to clash with azurerm module defintion
# variable "custom_container_apps" {
#   description = "Custom container apps, by default deployed within the container app environment"
#   type = map(object({
#     response_export_values = optional(list(string), [])
#     body = object({
#       properties = object({
#         managedEnvironmentId = optional(string, "")
#         configuration = object({
#           activeRevisionsMode = optional(string, "single")
#           secrets             = optional(list(map(string)), [])
#           ingress             = optional(any, {})
#           registries          = optional(list(map(any)), [])
#           dapr                = optional(map(string), {})
#         })
#  #       template = object({
#           revisionSuffix = string
#           containers     = list(any)
#           scale          = map(any)
#           volumes        = list(map(string))
# # @note added required parameters as specified by validate results below
#           cpu            = number
#           command        = string
#           image          = string
#           max_replicas   = number
#           min_replicas   = number
#           memory         = number
#   #      })
#       })
#     })
#   }))
#   default = {}
# }

variable "application_env" {
  description = "Application environment variables, which are defined as `secrets` within the container app configuration. This is to help reduce the risk of accidentally exposing secrets."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "enable_container_registry" {
  description = "Set to true to create a container registry"
  type        = bool
}

variable "docker_registry_password" {
  description = "Container registry password (required if `enable_container_registry` is false)"
  type        = string
  default     = ""
}

variable "docker_registry_username" {
  description = "Container registry username (required if `enable_container_registry` is false)"
  type        = string
  default     = ""
}

variable "docker_image_registry" {
  description = "Container registry server (required if `enable_container_registry` is false)"
  type        = string
  default     = "ghcr.io"
}

variable "docker_image" {
  description = "Docker image name, the application will run this image"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker image tag, the application will run this tag"
  type        = string
}

variable "container_port" {
  description = "Container port, which port to expose traffic to"
  type        = number
  default     = 80
}

variable "container_command" {
  description = "Container command, the command to be run on the container"
  type        = list(any)
  default     = ["/bin/bash", "-c", "bundle exec rails db:prepare && bundle exec rails s -p 80 -b '0.0.0.0'"]
}

variable "container_cpu" {
  description = "Number of container CPU cores"
  type        = number
  default     = 1
}

variable "container_memory" {
  description = "Container memory in GB"
  type        = number
  default     = 2
}

variable "container_scale_rule_concurrent_request_count" {
  description = "Maximum number of concurrent HTTP requests before a new replica is created"
  type        = number
  default     = 10
}

variable "container_min_replicas" {
  description = "Container min replicas"
  type        = number
  default     = 1
}

variable "container_max_replicas" {
  description = "Container max replicas"
  type        = number
  default     = 2
}

variable "enable_worker_container" {
  description = "Conditionally launch a worker container. This container uses the same image and environment variables as the default container app, but allows a different container command to be run. The worker container does not expose any ports."
  type        = bool
  default     = false
}

variable "worker_container_command" {
  description = "Container command for the Worker container. `enable_worker_container` must be set to true for this to have any effect."
  type        = list(string)
  default     = []
}

variable "worker_container_min_replicas" {
  description = "Worker container min replicas"
  type        = number
  default     = 1
}

variable "worker_container_max_replicas" {
  description = "Worker container max replicas"
  type        = number
  default     = 2
}

variable "enable_container_health_probe" {
  description = "Enable liveness probes for the Container"
  type        = bool
  default     = true
}

variable "container_health_probe_interval" {
  description = "How often in seconds to poll the Container to determine liveness"
  type        = number
  default     = 30
}

variable "container_health_probe_path" {
  description = "Specifies the path that is used to determine the liveness of the Container"
  type        = string
  default     = "/"
}

variable "container_health_probe_protocol" {
  description = "Use HTTPS or a TCP connection for the Container liveness probe"
  type        = string
  default     = "https"
}

variable "enable_monitoring" {
  description = "Create an App Insights instance and notification group for the Container App"
  type        = bool
  default     = false
}

variable "monitoring_endpoint_healthcheck" {
  description = "Specify a route that should be monitored for a 200 OK status"
  type        = string
  default     = "/"
}

variable "monitoring_alarm_cpu_threshold_percentage" {
  description = "Specify a number (%) which should be set as a threshold for a CPU usage monitoring alarm"
  type        = number
  default     = 80
}

variable "monitoring_alarm_memory_threshold_percentage" {
  description = "Specify a number (%) which should be set as a threshold for a memory usage monitoring alarm"
  type        = number
  default     = 80
}

variable "monitoring_alarm_latency_threshold_ms" {
  description = "Specify a number in milliseconds which should be set as a threshold for a request latency monitoring alarm"
  type        = number
  default     = 1000
}

variable "enable_dns_zone" {
  description = "Conditionally create a DNS zone"
  type        = bool
  default     = false
}

variable "dns_zone_domain_name" {
  description = "DNS zone domain name. If created, records will automatically be created to point to the CDN."
  type        = string
  default     = ""
}

variable "cdn_frontdoor_custom_domains" {
  description = "Azure CDN Front Door custom domains"
  type        = list(string)
  default     = []
}

variable "connect_dns_to_parent_zone" {
  description = "Should the created DNS zone be added automatically to the parent DNS zone?"
  type        = bool
}

variable "parent_dns_zone_record_name" {
  description = "Name given to the NS record created within the parent DNS zone (when enabling connect_dns_to_parent_zone)"
  type        = string
}

variable "parent_dns_zone_resource_group_name" {
  description = "Name of the resource group which holds the parent DNS zone"
  type        = string
}

variable "monitoring_email_receivers" {
  description = "A list of email addresses that should be notified by monitoring alerts"
  type        = list(string)
  default     = []
}

variable "monitoring_enable_slack_webhook" {
  description = "Enable slack webhooks to send monitoring notifications to a channel. Has no effect if you have defined `existing_logic_app_workflow`"
  type        = bool
  default     = false
}

variable "monitoring_slack_webhook_receiver" {
  description = "A Slack App webhook URL. Has no effect if you have defined `existing_logic_app_workflow`"
  type        = string
  default     = ""
}

variable "monitoring_slack_channel" {
  description = "Slack channel name/id to send messages to. Has no effect if you have defined `existing_logic_app_workflow`"
  type        = string
  default     = ""
}

variable "enable_cdn_frontdoor" {
  description = "Enable Azure CDN Front Door. This will use the Container Apps endpoint as the origin."
  type        = bool
  default     = false
}

variable "restrict_container_apps_to_cdn_inbound_only" {
  description = "Restricts access to the Container Apps by creating a network security group that only allows 'AzureFrontDoor.Backend' inbound, and attaches it to the subnet of the container app environment."
  type        = bool
  default     = true
}

variable "enable_cdn_frontdoor_health_probe" {
  description = "Enable CDN Front Door health probe"
  type        = bool
  default     = true
}

variable "cdn_frontdoor_health_probe_interval" {
  description = "Specifies the number of seconds between health probes."
  type        = number
  default     = 120
}

variable "cdn_frontdoor_health_probe_path" {
  description = "Specifies the path relative to the origin that is used to determine the health of the origin."
  type        = string
  default     = "/"
}

variable "cdn_frontdoor_health_probe_request_type" {
  description = "Specifies the type of health probe request that is made."
  type        = string
  default     = "GET"
}

variable "cdn_frontdoor_origin_host_header_override" {
  description = "Manually specify the host header that the CDN sends to the target. Defaults to the received host header. Set to null to set it to the host_name (`cdn_frontdoor_origin_fqdn_override`)"
  type        = string
  default     = ""
  nullable    = true
}

variable "enable_redis_cache" {
  description = "Set to true to create an Azure Redis Cache, with a private endpoint within the virtual network"
  type        = bool
  default     = false
}

variable "redis_cache_version" {
  description = "Redis Cache version"
  type        = number
  default     = 6
}

variable "redis_cache_family" {
  description = "Redis Cache family"
  type        = string
  default     = "C"
}

variable "redis_cache_sku" {
  description = "Redis Cache SKU"
  type        = string
  default     = "Basic"
}

variable "redis_cache_capacity" {
  description = "Redis Cache Capacity"
  type        = number
  default     = 0
}

variable "redis_cache_patch_schedule_day" {
  description = "Redis Cache patch schedule day"
  type        = string
  default     = "Sunday"
}

variable "redis_cache_patch_schedule_hour" {
  description = "Redis Cache patch schedule hour"
  type        = number
  default     = 18
}

variable "redis_cache_firewall_ipv4_allow_list" {
  description = "A list of IPv4 address that require remote access to the Redis server"
  type        = list(string)
  default     = []
}


variable "enable_postgresql_database" {
  type        = bool
  description = "Set to true to create an Azure Postgres server/database, with a private endpoint within the virtual network"
  default     = false
}

variable "postgresql_server_version" {
  type        = string
  description = "Specify the version of postgres server to run (either 11,12,13 or 14)"
  default     = ""
}

variable "postgresql_administrator_login" {
  type        = string
  description = "Specify a login that will be assigned to the administrator when creating the Postgres server"
  default     = ""
}

variable "postgresql_administrator_password" {
  type        = string
  description = "Specify a password that will be assigned to the administrator when creating the Postgres server"
  default     = ""
}

variable "postgresql_availability_zone" {
  type        = string
  description = "Specify the availability zone in which the Postgres server should be located"
  default     = "1"
}

variable "postgresql_max_storage_mb" {
  type        = number
  description = "Specify the max amount of storage allowed for the Postgres server"
  default     = 32768
}

variable "postgresql_sku_name" {
  type        = string
  description = "Specify the SKU to be used for the Postgres server"
  default     = "B_Standard_B1ms"
}

variable "postgresql_collation" {
  type        = string
  description = "Specify the collation to be used for the Postgres database"
  default     = "en_US.utf8"
}

variable "postgresql_charset" {
  type        = string
  description = "Specify the charset to be used for the Postgres database"
  default     = "utf8"
}

variable "postgresql_enabled_extensions" {
  type        = string
  description = "Specify a comma separated list of Postgres extensions to enable. See https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-extensions#postgres-14-extensions"
  default     = ""
}

variable "postgresql_network_connectivity_method" {
  type        = string
  description = "Specify postgresql networking method, public or private. See https://learn.microsoft.com/en-gb/azure/postgresql/flexible-server/concepts-networking"
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.postgresql_network_connectivity_method)
    error_message = "Valid values for postgresql_network_connectivity_method are public or private."
  }
}

variable "postgresql_firewall_ipv4_allow" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  description = "Map of IP address ranges to add into the postgres firewall. Note: only applicable if postgresql_network_connectivity_method is set to public."
  default     = {}
}

variable "enable_container_app_blob_storage" {
  description = "Create an Azure Storage Account and Storage Container to be used for this app"
  type        = bool
  default     = false
}

variable "container_app_blob_storage_public_access_enabled" {
  description = "Should the Azure Storage Account have Public visibility?"
  type        = bool
  default     = false
}

variable "storage_account_ipv4_allow_list" {
  description = "A list of public IPv4 address to grant access to the Blob Storage Account"
  type        = list(string)
  default     = []
}

variable "enable_key_vault_tfvars" {
  description = "Enable keyvault tfvars backup"
  type        = bool
  default     = false
}

variable "key_vault_access_users" {
  description = "List of users that require access to the Key Vault. This should be a list of User Principle Names (Found in Active Directory) that need to run terraform"
  type = list(string)
  default = []
}

variable "key_vault_access_ipv4" {
  description = "List of IPv4 Addresses that are permitted to access the Key Vault"
  type        = list(string)
}

variable "key_vault_tfvars_filename" {
  description = "tfvars filename. This file is uploaded and stored encrypted within Key Vault, to ensure that the latest tfvars are stored in a shared place."
  type        = string
}

variable "key_vault_enable_diagnostic_setting" {
  description = "Enable Azure Diagnostics setting for the Key Vault"
  type        = bool
  default     = true
}
