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

variable "vpc_id" {
  type = string
  default="vpc-0b6151bb9b43b3c35"
}


source "amazon-ebs" "java21" {
  region           = "us-east-1"
  source_ami       = "ami-0199fa5fada510433"   # Latest Amazon Linux 2
  instance_type    = "t3.medium"
  ssh_username     = "ec2-user"
  ami_name         = "${var.env}-java21-golden-{{timestamp}}"

  # Optional: if you want to keep it in private VPC
  vpc_id           = var.vpc_id
  associate_public_ip_address = false
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