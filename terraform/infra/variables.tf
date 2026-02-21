variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "private_subnet_1" {
  default = "10.10.1.0/24"
}

variable "private_subnet_2" {
  default = "10.10.2.0/24"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "Password123!"
}

variable "microservice_ami" {
  default = "ami-xxxxxxxx" # Your baked microservice AMI
}

variable "nginx_ami" {
  default = "ami-yyyyyyyy" # Your baked NGINX AMI
}