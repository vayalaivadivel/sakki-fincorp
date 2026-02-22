variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnet_1" {
  default = "10.0.1.0/24"
}

variable "private_subnet_2" {
  default = "10.0.2.0/24"
}

variable "microservice_ami" {
  type = string
}

variable "nginx_ami" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}