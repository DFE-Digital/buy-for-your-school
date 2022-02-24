data "cloudfoundry_org" "org" {
  name = local.cloudfoundry_org
}

data "cloudfoundry_domain" "shared" {
  name = local.shared_cloudfoundry_domain
}

data "cloudfoundry_domain" "custom" {
  name = local.custom_cloudfoundry_domain
}

data "cloudfoundry_service" "redis" {
  name = "redis"
}

data "cloudfoundry_service" "postgres" {
  name = "postgres"
}

data "cloudfoundry_service" "s3" {
  name = "aws-s3-bucket"
}

data "cloudfoundry_space" "space" {
  name = local.cloudfoundry_space
  org  = data.cloudfoundry_org.org.id
}

data "cloudfoundry_domain" "publish_service_gov_uk" {
  name = local.service_gov_uk_domain
}
