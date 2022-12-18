output "vpc_id" {
  value = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
  description = "The ID of Public Subnet A"
}

output "public_subnet_a_az" {
  value = aws_subnet.public_subnet_a.availability_zone
  description = "The Availablity Zone of Public Subnet A"
}

output "public_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
  description = "The ID of Public Subnet B"
}

output "public_subnet_b_az" {
  value = aws_subnet.public_subnet_b.availability_zone
  description = "The Availablity Zone of Public Subnet B"
}

output "public_rt" {
  value = aws_route_table.public_rt.id
  description = "The ID of the Public Route Table"
}