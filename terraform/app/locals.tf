locals {
  project_name = var.project_name
  environment  = var.environment

  cloudfoundry_org           = var.cloudfoundry_org
  cloudfoundry_space         = local.environment == "prod" ? "sct-production" : "sct-${local.environment}"
  shared_cloudfoundry_domain = var.shared_cloudfoundry_domain
  custom_cloudfoundry_domain = var.custom_cloudfoundry_domain

  custom_hostname = local.environment == "prod" ? "get-help-buying-for-schools" : "${local.environment}-get-help-buying-for-schools"

  redis_class    = var.redis_class
  redis_timeouts = var.redis_timeouts

  postgres_class       = local.environment == "prod" ? var.postgres_class_prod : var.postgres_class
  postgres_json_params = jsonencode(var.postgres_json_params)
  postgres_timeouts    = var.postgres_timeouts

  s3_params = {
    bucket = "ghbs-${local.environment}-bucket"
    acl    = "private"
  }
  s3_json_params = jsonencode(local.s3_params)

  app_env_yaml_file = file("${local.environment}_app_env.yml")
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

  web_app_docker_image               = var.docker_image
  web_app_instances                  = var.web_app_instances
  web_app_disk_quota                 = var.web_app_disk_quota
  web_app_timeout                    = var.web_app_timeout
  web_app_health_check_http_endpoint = var.web_app_health_check_http_endpoint

  web_worker_command              = var.web_worker_command
  web_worker_docker_image         = var.docker_image
  web_worker_instances            = var.web_worker_instances
  web_worker_disk_quota           = var.web_worker_disk_quota
  web_worker_timeout              = var.web_worker_timeout
  web_worker_health_check_timeout = 180
}
