packer {
  required_version = ">= 1.9.0"
  required_plugins {
    amazon = {
      version = ">= 1.8.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ami_name" {
  type    = string
  default = "java21-golden-{{timestamp}}"
}

source "amazon-ebs" "java21" {
  region                  = var.aws_region
  instance_type           = "t3.micro"
  ami_name                = var.ami_name
  vpc_id                  = var.vpc_id
  subnet_id               = var.subnet_ids[0]
  associate_public_ip_address = true

  ssh_username = "ec2-user"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-kernel-default*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
}

build {
  sources = ["source.amazon-ebs.java21"]

  provisioner "shell" {
    inline = [
      # Update base OS packages
      "sudo dnf update -y",

      # Install required utilities (skip curl to avoid conflict)
      "sudo dnf install -y wget unzip git",

      # Download and install Java 21 Corretto RPM
      "wget https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.rpm -O /tmp/corretto21.rpm",
      "sudo dnf install -y /tmp/corretto21.rpm",

      # Verify Java
      "java -version"
    ]
  }

  # Optional cleanup to reduce AMI size
  provisioner "shell" {
    inline = [
      "sudo dnf clean all",
      "sudo rm -rf /tmp/* /var/tmp/*"
    ]
  }
}