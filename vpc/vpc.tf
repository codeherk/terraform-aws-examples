# Create the VPC
resource "aws_vpc" "main" {
  cidr_block       = var.main_vpc_cidr     
  instance_tenancy = "default"
  tags             = {
    "Name"         = "tf-vpc-example"
  }
 }

# Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id           = aws_vpc.main.id                # vpc_id will be generated after we VPC is created
  tags             = {
    "Name"         = "tf-igw-example"
  }
}

# Create two Public Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id           =  aws_vpc.main.id
  cidr_block       = "${var.public_subnet_range_a}"
  tags             = {
    "Name"         = "tf-public-subnet-example-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id           =  aws_vpc.main.id
  cidr_block       = "${var.public_subnet_range_b}"
  tags             = {
    "Name"         = "tf-public-subnet-example-b"
  }
}

# Create Route table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id           =  aws_vpc.main.id
  route {
    # Traffic from Public Subnet reaches Internet via Internet Gateway
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.igw.id
  }

  tags             = {
    "Name"         = "tf-rt-example"
  }
}

# Route table Association with Public Subnet A
resource "aws_route_table_association" "public_rt_association_a" {
  subnet_id        = aws_subnet.public_subnet_a.id
  route_table_id   = aws_route_table.public_rt.id
}

# Route table Association with Public Subnet B
resource "aws_route_table_association" "public_rt_association_b" {
  subnet_id        = aws_subnet.public_subnet_b.id
  route_table_id   = aws_route_table.public_rt.id
}