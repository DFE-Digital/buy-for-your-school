terraform {
  backend "s3" {
    bucket = "paas-s3-broker-prod-lon-b2db1a0a-5a37-488b-858f-5e850ff4fdfb"
    key    = "terraform"
    region = "eu-west-2"
  }
}
