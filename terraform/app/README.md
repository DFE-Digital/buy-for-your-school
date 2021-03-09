# Terraform Deployment

We use terraform to create the services needed by the application and to deploy the application itself.

We use terraform workspaces to keep the terraform state seperate for each environment.

At the time of writing, we store our state in an s3 bucket on the PaaS in the `sct-research` space. This is planned to move to a new space, `sct-terraform`.

### Setup

- go to the application `/terraform` directory
- install [tfenv](https://github.com/tfutils/tfenv)
- run `tfenv install` to install the vesion of terraform specified in `.terraform-version`
- ask the tech lead for access to the service within DfE's central GPaaS account
- set the `cloudfoundry` provider credentials (GPaas username/password):
```
$ export CF_USER="username"
$ export CF_PASSWORD="password"
```
- get the terraform state S3 Bucket AWS credentials
```
$ cf target -s sct-research
$ cf service-key terraform-state terraform-state-key
{
 "aws_access_key_id": "AWS_ACCESS_KEY",
 "aws_region": "AWS_REGION",
 "aws_secret_access_key": "AWS_SECRET_ACCESS_KEY",
 "bucket_name": "BUCKET_NAME",
 "deploy_env": ""
}
```
- set the AWS credentials:
```
$ export AWS_REGION=aws_region
$ export AWS_ACCESS_KEY_ID=aws_access_key_id
$ export AWS_SECRET_ACCESS_KEY=aws_secret_access_key
```
