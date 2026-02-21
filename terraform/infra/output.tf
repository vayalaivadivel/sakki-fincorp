###############################
# NGINX EC2 Private IP
###############################
output "nginx_private_ip" {
  description = "Private IP of the NGINX EC2 instance"
  value       = aws_instance.nginx.private_ip
}

###############################
# Microservice EC2 Private IPs (ASG)
###############################
data "aws_instances" "microservice" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.microservice_asg.name]
  }
}

###############################
# RDS Private Endpoint
###############################
output "rds_endpoint" {
  description = "Private endpoint of RDS instance"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.mysql.port
}