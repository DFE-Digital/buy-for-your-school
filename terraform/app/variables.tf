variable "environment" {
  description = "Environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  default     = "buy-for-your-school"
  type        = string
}

variable "cloudfoundry_org" {
  description = "CloudFoundry Org"
  default     = "dfe"
  type        = string
}

variable "cloudfoundry_space" {
  description = "CloudFoundry Space e.g. sct-production"
  default     = ""
  type        = string
}

variable "shared_cloudfoundry_domain" {
  description = "Shared Cloud Foundry domain"
  default     = "london.cloudapps.digital"
  type        = string
}

variable "custom_cloudfoundry_domain" {
  description = "Custom Cloud Foundry domain"
  default     = "education.gov.uk"
  type        = string
}

variable "redis_class" {
  description = "Redis class"
  default     = "tiny-5_x"
  type        = string
}

variable "redis_timeouts" {
  description = "Redis timeouts"
  default = {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
  type = map(string)
}

variable "postgres_class" {
  description = "Postgres class"
  default     = "small-11"
  type        = string
}

variable "postgres_class_prod" {
  description = "Postgres class (Production environment)"
  default     = "medium-ha-11"
  type        = string
}

variable "postgres_json_params" {
  description = "Postgres json_params"
  default = {
    enable_extensions = [
      "pgcrypto",
      "plpgsql",
      "pg_trgm",
    ]
  }
  type = map(any)
}

variable "postgres_timeouts" {
  description = "Postgres timeouts"
  default = {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
  type = map(string)
}

variable "docker_image" {
  description = "Docker image"
  default     = ""
  type        = string
}

variable "syslog_drain_url" {
  description = "Syslog drain URL"
  type        = string
}

variable "web_app_instances" {
  description = "Web app instance number"
  default     = 2
  type        = number
}

variable "web_app_disk_quota" {
  description = "Web app disk quota"
  default     = 3072
  type        = number
}

variable "web_app_timeout" {
  description = "Web app timeout"
  default     = 300
  type        = number
}

variable "web_app_health_check_http_endpoint" {
  description = "Web app health check HTTP endpoint"
  default     = "/health_check"
  type        = string
}

variable "web_worker_instances" {
  description = "Web worker instance number"
  default     = 1
  type        = number
}

variable "web_worker_disk_quota" {
  description = "Web worker disk quota"
  default     = 3072
  type        = number
}

variable "web_worker_timeout" {
  description = "Web worker timeout"
  default     = 300
  type        = number
}

variable "web_worker_health_check_timeout" {
  description = "Web worker health check timeout"
  default     = 10
  type        = number
}

variable "web_worker_command" {
  description = "Web worker command"
  default     = "bundle exec sidekiq -C config/sidekiq.yml"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the running s3 bucket"
  type        = string
}
