resource "cloudfoundry_service_instance" "redis" {
  name         = local.redis_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[local.redis_class]
  timeouts {
    create = local.redis_timeouts.create
    update = local.redis_timeouts.update
    delete = local.redis_timeouts.delete
  }
}
