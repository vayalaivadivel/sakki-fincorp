packer {
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

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "source_ami" {
  type    = string
  default = "ami-0c55b159cbfafe1f0" # Amazon Linux 2023 in us-east-1
}


source "amazon-ebs" "java21" {
  region        = var.region
  instance_type = var.instance_type
  source_ami    = var.source_ami
  ssh_username  = "ec2-user"
  ami_name      = "${var.env}-java21-golden-{{timestamp}}"
  tags = {
    Name = "${var.env}-java21-golden"
    Env  = var.env
  }
}

build {
  sources = ["source.amazon-ebs.java21"]

  provisioner "shell" {
    inline = [
      # Remove conflicting curl-minimal
      "sudo dnf remove -y curl-minimal || true",

      # Update system and install wget + curl
      "sudo dnf -y update",
      "sudo dnf -y install wget curl",

      # Download and install Java 21
      "wget https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.rpm",
      "sudo rpm -ivh amazon-corretto-21-x64-linux-jdk.rpm",

      # Verify Java installation
      "java -version"
    ]
  }
}