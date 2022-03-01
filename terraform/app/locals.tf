locals {
  project_name = var.project_name
  environment  = var.environment

  cloudfoundry_org           = var.cloudfoundry_org
  cloudfoundry_space         = var.cloudfoundry_space == "" ? (local.environment == "prod" ? "sct-production" : "sct-${local.environment}") : var.cloudfoundry_space
  cdn_route_name             = local.environment == "prod" ? "get-help-buying-for-schools" : "get-help-buying-for-schools-${local.environment}"
  shared_cloudfoundry_domain = var.shared_cloudfoundry_domain
  custom_cloudfoundry_domain = var.custom_cloudfoundry_domain
  custom_hostname            = local.environment == "prod" ? "get-help-buying-for-schools" : "${local.environment}-get-help-buying-for-schools"
  custom_full_domain         = "${local.custom_hostname}.${local.custom_cloudfoundry_domain}"
  custom_route_count         = local.environment == "prod" || local.environment == "staging" ? 1 : 0
  service_gov_uk_domain      = "get-help-buying-for-schools.service.gov.uk"
  service_gov_uk_subdomain   = local.environment == "prod" ? "www" : local.environment
  service_gov_uk_route_count = local.environment == "prod" ? 1 : 0

  redis_name     = var.redis_name == "" ? "${local.environment}-redis" : var.redis_name
  redis_class    = var.redis_class
  redis_timeouts = var.redis_timeouts

  postgres_name        = "${local.environment}-postgres"
  postgres_class       = local.environment == "prod" ? var.postgres_class_prod : var.postgres_class
  postgres_json_params = jsonencode(var.postgres_json_params)
  postgres_timeouts    = var.postgres_timeouts

  s3_name = "${local.environment}-s3"
  s3_bucket_name = var.s3_bucket_name == "" ? "${local.environment}-s3-bucket" : var.s3_bucket_name
  s3_params = {
    bucket = local.s3_bucket_name
    acl    = "private"
  }
  s3_json_params = jsonencode(local.s3_params)

  app_env_yaml_file = file(var.app_yml_file == "" ? "${local.environment}_app_env.yml" : var.app_yml_file)
  app_env           = yamldecode(local.app_env_yaml_file)
  domain            = "${local.project_name}-${local.environment}.${local.shared_cloudfoundry_domain}"
  app_env_domain = {
    "DOMAIN" = local.domain
  }
  app_environment = merge(
    local.app_env_domain,
    local.app_env,
  )

  syslog_drain_url = var.syslog_drain_url

  web_app_name                       = "${local.project_name}-${local.environment}"
  web_app_docker_image               = var.docker_image
  web_app_instances                  = var.web_app_instances
  web_app_disk_quota                 = var.web_app_disk_quota
  web_app_timeout                    = var.web_app_timeout
  web_app_health_check_http_endpoint = var.web_app_health_check_http_endpoint

  web_worker_name                 = "${local.project_name}-${local.environment}-worker"
  web_worker_command              = var.web_worker_command
  web_worker_docker_image         = var.docker_image
  web_worker_instances            = var.web_worker_instances
  web_worker_disk_quota           = var.web_worker_disk_quota
  web_worker_timeout              = var.web_worker_timeout
  web_worker_health_check_timeout = 180
}
