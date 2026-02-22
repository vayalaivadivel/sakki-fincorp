############################
# Variables
############################
variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name (dev, prod, etc.)"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to build AMI in"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type for building AMI"
}

variable "source_ami" {
  type        = string
  default     = "ami-01aad667f16a905c7" # Amazon Linux 2023 latest x86_64 in us-east-1
  description = "Base AMI to use"
}

############################
# Source (Amazon EBS)
############################
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

############################
# Build
############################
build {
  sources = ["source.amazon-ebs.java21"]

  provisioner "shell" {
    inline = [
      # Update all packages
      "sudo dnf -y upgrade",
      
      # Install wget and curl (avoiding conflicts)
      "sudo dnf -y install wget curl",

      # Download Amazon Corretto 21 RPM
      "wget https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.rpm -O /tmp/amazon-corretto-21-x64-linux-jdk.rpm",

      # Install Java 21
      "sudo dnf -y localinstall /tmp/amazon-corretto-21-x64-linux-jdk.rpm",

      # Verify installation
      "java -version"
    ]
  }
}