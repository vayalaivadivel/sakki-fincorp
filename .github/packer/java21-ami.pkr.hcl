# java21-ami.pkr.hcl

# ==============================
# Variables
# ==============================
variable "env" {
  type    = string
  default = "dev"
  description = "Environment name (dev, prod, etc.)"
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
  default = "ami-01aad667f16a905c7" # Amazon Linux 2023 minimal
}

variable "ami_name" {
  type    = string
  default = "${var.env}-java21-golden-{{timestamp}}"
}

# ==============================
# Builder
# ==============================
source "amazon-ebs" "java21" {
  region                 = var.region
  instance_type          = var.instance_type
  source_ami             = var.source_ami
  ssh_username           = "ec2-user"
  ami_name               = var.ami_name
  associate_public_ip_address = true
}

# ==============================
# Provisioners
# ==============================
build {
  sources = ["source.amazon-ebs.java21"]

  provisioner "shell" {
    inline = [
      "set -e",
      "echo 'Updating system packages...'",
      "sudo dnf -y update",

      # Remove conflicting curl-minimal if exists
      "sudo dnf remove -y curl-minimal || true",

      # Install standard curl, wget, and unzip
      "sudo dnf install -y curl wget unzip",

      # Download and install Amazon Corretto 21 manually
      "echo 'Installing Amazon Corretto 21...'",
      "curl -L -o /tmp/amazon-corretto-21-x64-linux-jdk.rpm https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.rpm",
      "sudo dnf install -y /tmp/amazon-corretto-21-x64-linux-jdk.rpm",

      # Verify installation
      "java -version",
      "javac -version"
    ]
  }
}