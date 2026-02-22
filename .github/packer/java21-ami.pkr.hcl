###############################################
# Packer HCL2 Template for Java 21 AMI
# Amazon Linux 2023 + Java 21 Corretto RPM
###############################################

packer {
  required_version = ">= 1.9.0"

  required_plugins {
    amazon = {
      version = ">= 1.8.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "env" {
  type    = string
  default = "dev"
}

variable "java_version" {
  type    = string
  default = "21"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name_prefix" {
  type    = string
  default = "java21-golden"
}

source "amazon-ebs" "java21" {
  ami_name      = "${var.ami_name_prefix}-{{timestamp}}"
  instance_type = "t3.micro"
  region        = var.region
  ssh_username  = "ec2-user"

  # Optional: Use a specific VPC/subnet if needed
  # vpc_id    = "vpc-xxxxxxxx"
  # subnet_id = "subnet-xxxxxxxx"

  # Amazon Linux 2023 base AMI
  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["137112412989"]
    most_recent = true
  }

  tags = {
    Name        = "${var.ami_name_prefix}-${var.env}"
    Environment = var.env
  }
}

build {
  sources = ["source.amazon-ebs.java21"]

  # Install Java 21 via RPM
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y wget",
      "wget https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.rpm",
      "sudo dnf install -y amazon-corretto-21-x64-linux-jdk.rpm",
      "java -version"
    ]
  }

  # Optional: install additional tools
  provisioner "shell" {
    inline = [
      "sudo dnf install -y git wget curl unzip"
    ]
  }
}