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

resource "cloudfoundry_route" "live_route" {
  domain   = data.cloudfoundry_domain.live.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.live_hostname
}
