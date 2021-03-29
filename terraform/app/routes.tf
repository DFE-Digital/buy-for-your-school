resource "cloudfoundry_route" "shared_route" {
  domain   = data.cloudfoundry_domain.shared.id
  space    = data.cloudfoundry_space.space.id
  hostname = "${local.project_name}-${local.environment}"
}
