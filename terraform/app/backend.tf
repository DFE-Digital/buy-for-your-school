terraform {
  backend "s3" {
    bucket = "paas-s3-broker-prod-lon-04cdce2c-ebd3-4525-924e-d6ce670d2ee3"
    key    = "terraform"
    region = "eu-west-2"
  }
}
