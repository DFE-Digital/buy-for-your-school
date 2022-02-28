resource cloudfoundry_service_instance s3 {
  name         = local.s3_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.s3.service_plans["default"]
}
