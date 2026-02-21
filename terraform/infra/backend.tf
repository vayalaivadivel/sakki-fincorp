# terraform init -reconfigure -force-copy
# terraform state push terraform.tfstate
terraform {
  backend "s3" {
    bucket  = "vadivel-tf-state-buc"
    key     = "sakki-fincorp-microservices-dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}