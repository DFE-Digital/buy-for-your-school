# Terraform Deployment

We use terraform to create the services needed by the application and to deploy the application itself.

We use terraform workspaces to keep the terraform state seperate for each environment.

At the time of writing, we store our state in an s3 bucket on the PaaS in the `sct-research` space. This is planned to move to a new space, `sct-terraform`.

### Setup

- go to the application `/terraform/app` directory
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
- initialise terraform to test the local environment:
```
terraform init
```

### Deploying

- copy: `$PROJECT_PATH/terraform/workspace-variables/<environment>.tfvars.example`
  to: `$PROJECT_PATH/terraform/workspace-variables/app/<environment>.tfvars`
- copy: `$PROJECT_PATH/terraform/workspace-variables/<environment>_app_env.yml.example`
  to: `$PROJECT_PATH/terraform/workspace-variables/app/<environment>_app_env.yml`
- ask the Tech Lead for the environment's variables for `tfvars` and `app_env.yml` files
- change to the relevant terraform workspace:
```
$ terraform workspace list
$ terraform workspace select <environment>
```
- without any changes, ensure that this does not invoke any infrastructure changes:
```
$ terraform plan -var-file=<environment>.tfvars
[...]

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```
- once you have modified or added any resources, deploy them:
```
$ terraform apply -var-file=<environment>.tfvars
```
- ensure a Pull Request is opened with the changes and merged in, otherwise the resources will be destroyed if terraform apply is ran elsewhere
