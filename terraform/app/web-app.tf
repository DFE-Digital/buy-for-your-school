resource "cloudfoundry_app" "web_app" {
  name                       = "${local.project_name}-${local.environment}"
  space                      = data.cloudfoundry_space.space.id
  instances                  = local.web_app_instances
  disk_quota                 = local.web_app_disk_quota
  timeout                    = local.web_app_timeout
  docker_image               = local.web_app_docker_image
  strategy                   = "blue-green-v2"
  health_check_http_endpoint = local.web_app_health_check_http_endpoint

  service_binding { service_instance = cloudfoundry_service_instance.redis.id }
  service_binding { service_instance = cloudfoundry_service_instance.postgres.id }

  environment = local.app_environment

  routes {
    route = cloudfoundry_route.shared_route.id
  }
}
