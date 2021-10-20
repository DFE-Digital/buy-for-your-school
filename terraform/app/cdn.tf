data "cloudfoundry_service" "cdn_route" {
  name = "cdn-route"
}

resource "cloudfoundry_service_instance" "cdn_route" {

  count = local.environment == "prod" ? 1 : (local.environment == "staging" ? 1 : 0)

  name = local.environment == "prod" ? "get-help-buying-for-schools" : "get-help-buying-for-schools-${local.environment}"

  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.cdn_route.service_plans["cdn-route"]
  json_params = jsonencode(
    {
      custom_domain = "${local.custom_hostname}.${local.custom_cloudfoundry_domain}"
      live_domain   = "${local.live_hostname}.${local.live_cloudfoundry_domain}"
    }
  )
  lifecycle {
    prevent_destroy = true
  }
}
