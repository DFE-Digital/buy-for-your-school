resource "cloudfoundry_app" "web_worker" {
  name                       = "${local.project_name}-worker-${local.environment}"
  command                    = local.web_worker_command
  space                      = data.cloudfoundry_space.space.id
  instances                  = local.web_worker_instances
  disk_quota                 = local.web_worker_disk_quota
  timeout                    = local.web_worker_timeout
  docker_image               = local.web_worker_docker_image
  strategy                   = "blue-green-v2"
  health_check_type          = "process"
  health_check_timeout       = local.web_worker_health_check_timeout
  health_check_http_endpoint = local.web_app_health_check_http_endpoint

  service_binding { service_instance = cloudfoundry_service_instance.redis.id }
  service_binding { service_instance = cloudfoundry_service_instance.postgres.id }
  service_binding { service_instance = cloudfoundry_service_instance.s3.id }
  service_binding { service_instance = cloudfoundry_user_provided_service.log_stream.id }

  environment = local.app_environment
}
