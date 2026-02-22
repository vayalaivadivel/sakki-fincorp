###############################
# VPC
###############################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "private-vpc" }
}

###############################
# Subnets
###############################
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1
  availability_zone = "${var.region}a"
  tags = { Name = "private-subnet-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2
  availability_zone = "${var.region}b"
  tags = { Name = "private-subnet-2" }
}

###############################
# Route Table
###############################
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private_1_assoc" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

###############################
# Security Groups
###############################
resource "aws_security_group" "microservice_sg" {
  name   = "microservice-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nginx_sg" {
  name   = "nginx-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.microservice_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################
# IAM
###############################
resource "aws_iam_role" "ec2_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

###############################
# Launch Template + ASG
###############################
resource "aws_launch_template" "microservice_lt" {
  name_prefix   = "microservice-"
  image_id      = var.microservice_ami
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.microservice_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
}

resource "aws_autoscaling_group" "microservice_asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  vpc_zone_identifier = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  launch_template {
    id      = aws_launch_template.microservice_lt.id
    version = "$Latest"
  }
}

###############################
# NGINX
###############################
resource "aws_instance" "nginx" {
  ami                    = var.nginx_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = false
}

###############################
# RDS
###############################
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "mysql" {
  identifier             = "private-db"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az            = true
  publicly_accessible = false
  backup_retention_period = 7
  storage_encrypted   = true

  skip_final_snapshot      = false
  final_snapshot_identifier = "private-db-final-${formatdate("20060102-150405", timestamp())}"
}