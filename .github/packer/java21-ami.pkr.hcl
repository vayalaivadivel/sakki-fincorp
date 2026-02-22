###############################################
# Packer HCL2 Template for Java 21 AMI
###############################################

packer {
  required_version = ">= 1.9.0"
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

  # Use latest Amazon Linux 2 as base AMI
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["137112412989"]
    most_recent = true
  }

  # Tags
  tags = {
    Name        = "${var.ami_name_prefix}-${var.env}"
    Environment = var.env
  }
}

build {
  sources = ["source.amazon-ebs.java21"]

  # Install Java 21
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras enable corretto${var.java_version}",
      "sudo yum install -y java-${var.java_version}-amazon-corretto-devel",
      "java -version"
    ]
  }

  # Optional: Additional dependencies
  provisioner "shell" {
    inline = [
      "sudo yum install -y git wget curl unzip"
    ]
  }
}