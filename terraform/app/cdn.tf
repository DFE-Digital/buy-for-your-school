data "cloudfoundry_service" "cdn_route" {
  name = "cdn-route"
}

resource "cloudfoundry_service_instance" "cdn_route" {
  count        = local.custom_route_count
  name         = "${local.custom_hostname}-cdn-route"
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.cdn_route.service_plans["cdn-route"]
  json_params = jsonencode(
    {
      domain = local.custom_full_domain
    }
  )
  lifecycle {
    prevent_destroy = true
  }
}
