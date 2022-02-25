resource "cloudfoundry_route" "shared_route" {
  domain   = data.cloudfoundry_domain.shared.id
  space    = data.cloudfoundry_space.space.id
  hostname = "${local.project_name}-${local.environment}"
}

resource "cloudfoundry_route" "custom_route" {
  domain   = data.cloudfoundry_domain.custom.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.custom_hostname
}

resource "cloudfoundry_route" "publish_service_gov_uk_route" {
  count    = local.service_gov_uk_route_count
  domain   = data.cloudfoundry_domain.publish_service_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.service_gov_uk_subdomain
  target {
    app = cloudfoundry_app.web_app.id
    port = 3000
  }
}
