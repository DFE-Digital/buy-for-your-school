# 22. Use Amazon S3 Storage for Document Storage requirements.

  

  

Date: 2022-01-07

  

  

## Status
  

![Accepted](https://img.shields.io/badge/adr-accepted-green)


## Context

* Case management system requires secure cloud storage to store case related documents.

* GOV.UK  Ruby applications often use [Amazon S3 storage and Rails Active Storage](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html#header) together and as it is preferred technical choice.

* A private aws-s3-bucket would be provisioned on Gov PaaS and only accessible via rails app  bind with the service.

  

## Decision

* Use Amazon S3 storage service on Gov PaaS and Rails Active Storage

## Consequences

  
* [AWS S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/) for development reference.

* Flexible storage option to meet different use cases.