variable "environment" {
  description = "Environment"
  type        = string
}

variable "app_yml_file" {
  description = "Location of the env var yml file"
  default     = ""
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
  description = "CloudFoundry Space"
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

variable "custom_hostname" {
  description = "Custom hostname - creates: <this value>.education.gov.uk"
  default     = ""
  type        = string
}

variable "redis_name" {
  description = "Redis name of service"
  default     = ""
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

variable "postgres_name" {
  description = "Postgres name of service"
  default     = ""
  type        = string
}

variable "postgres_class" {
  description = "Postgres class"
  default     = "small-11"
  type        = string
}

variable "postgres_class_prod" {
  description = "Postgres class (Production environment)"
  default     = "medium-11"
  type        = string
}

variable "postgres_json_params" {
  description = "Postgres json_params"
  default = {
    enable_extensions = [
      "pgcrypto",
      "plpgsql",
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

variable "web_app_name" {
  description = "Name of web_app, url will be: <value>.london.cloudapps.digital"
  default     = ""
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

variable "web_worker_name" {
  description = "Name of web_app_worker"
  default     = ""
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

variable "s3_name" {
  description = "s3 name of service"
  default     = ""
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the running s3 bucket"
  type        = string
}
