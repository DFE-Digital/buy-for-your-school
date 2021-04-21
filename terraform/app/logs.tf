resource "cloudfoundry_user_provided_service" "log_stream" {
  name             = "${local.project_name}-${local.environment}-log-stream"
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = local.syslog_drain_url
}
