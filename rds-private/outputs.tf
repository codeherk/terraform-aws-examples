###########################
########### VPC ###########
###########################
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "private_subnet_a_id" {
  value       = aws_subnet.private_subnet_a.id
  description = "The ID of Private Subnet A"
}

output "private_subnet_a_az" {
  value       = aws_subnet.private_subnet_a.availability_zone
  description = "The Availablity Zone of Private Subnet A"
}

output "private_subnet_b_id" {
  value       = aws_subnet.private_subnet_b.id
  description = "The ID of Private Subnet B"
}

output "private_subnet_b_az" {
  value       = aws_subnet.private_subnet_b.availability_zone
  description = "The Availablity Zone of Private Subnet B"
}

output "public_subnet_a_id" {
  value       = aws_subnet.public_subnet_a.id
  description = "The ID of Public Subnet A"
}

output "public_subnet_a_az" {
  value       = aws_subnet.public_subnet_a.availability_zone
  description = "The Availablity Zone of Public Subnet A"
}

output "private_rt" {
  value       = aws_route_table.private_rt.id
  description = "The ID of the Private Route Table"
}

output "public_rt" {
  value       = aws_route_table.public_rt.id
  description = "The ID of the Public Route Table"
}

output "default_sg_id" {
  value       = aws_security_group.default.id
  description = "The ID of the default security group"
}

###########################
########### EC2 ###########
###########################
output "ec2_public_ipv4" {
  value = aws_instance.go_api.public_ip
}

output "ec2_id" {
  value = aws_instance.go_api.id
}

###########################
########### RDS ###########
###########################
output "rds_sg_id" {
  value       = aws_security_group.rds_sg.id
  description = "The ID of the RDS security group"
}

output "rds_instance_id" {
  value = aws_db_instance.default.id
  description = "The ID of the RDS instance"
}
