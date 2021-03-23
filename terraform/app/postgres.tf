resource "cloudfoundry_service_instance" "postgres" {
  name         = "${local.environment}-postgres"
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[local.postgres_class]
  json_params  = local.postgres_json_params
  timeouts {
    create = local.postgres_timeouts.create
    update = local.postgres_timeouts.update
    delete = local.postgres_timeouts.delete
  }
}
