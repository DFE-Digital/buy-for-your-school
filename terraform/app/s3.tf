resource "cloudfoundry_service_instance" "s3" {
  name         = "${local.environment}-s3"
  space        = data.cloudfoundry_space.space.id
  service_plan = "default" # no other classes offered
  json_params  = local.s3_json_params
}
