# Create the VPC
resource "aws_vpc" "main" {
  cidr_block       = var.main_vpc_cidr
  instance_tenancy = "default"
  tags = {
    "Name" = "tf-vpc-example"
  }
}

# Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id # vpc_id will be generated after we VPC is created
  tags = {
    "Name" = "tf-igw-example"
  }
}

# Create 3 subnets: two private and one public
resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_range_a
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags = {
    "Name" = "${var.environment}-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_range_b
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"
  tags = {
    "Name" = "${var.environment}-private-subnet-b"
  }
}


resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_range_a
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    "Name" = "${var.environment}-public-subnet-a"
  }
}

# Create Route table for Private Subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.environment}-private-route-table"
  }
}

# Create Route table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    # Traffic from Public Subnet reaches Internet via Internet Gateway
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "${var.environment}-public-route-table"
  }
}

# Route table Association with Private Subnet A
resource "aws_route_table_association" "private_rt_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

# Route table Association with Private Subnet B
resource "aws_route_table_association" "private_rt_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

# Route table Association with Public Subnet A
resource "aws_route_table_association" "public_rt_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.main.id
  depends_on  = [aws_vpc.main]
}

# Allow inbound SSH for EC2 instances
resource "aws_security_group_rule" "allow_ssh_in" {
  description       = "Allow SSH"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Allow inbound HTTP for EC2 instances
resource "aws_security_group_rule" "allow_http_in" {
  description       = "Allow inbound HTTP traffic"
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Allow inbound HTTPS for EC2 instances
resource "aws_security_group_rule" "allow_https_in" {
  description       = "Allow inbound HTTPS traffic"
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "allow_http_in_api" {
  description       = "Allow inbound HTTPS traffic"
  type              = "ingress"
  from_port         = "8090"
  to_port           = "8090"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Allow all outbound traffic
resource "aws_security_group_rule" "allow_all_out" {
  description       = "Allow outbound traffic"
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}


###########################
########### RDS ###########
###########################

# RDS Subnet Group
resource "aws_db_subnet_group" "private_db_subnet" {
  name        = "mysql-rds-private-subnet-group"
  description = "Private subnets for RDS instance"
  # Subnet IDs must be in two different AZ. Define them explicitly in each subnet with the availability_zone property
  subnet_ids = ["${aws_subnet.private_subnet_a.id}", "${aws_subnet.private_subnet_b.id}"]
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-rds-sg"
  description = "Allow inbound/outbound MySQL traffic"
  vpc_id      = aws_vpc.main.id
  depends_on  = [aws_vpc.main]
}

# Allow inbound MySQL connections
resource "aws_security_group_rule" "allow_mysql_in" {
  description              = "Allow inbound MySQL connections"
  type                     = "ingress"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.default.id
  security_group_id        = aws_security_group.rds_sg.id
}

# RDS Instance
resource "aws_db_instance" "mysql_8" {
  # Storage for instance in gigabytes
  allocated_storage = 10
  # The name of the RDS instance
  identifier = "codeherk-tf-db"
  # See storage comparision https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#storage-comparison
  storage_type = "gp2"
  # Specific Relational Database Software https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html#Welcome.Concepts.DBInstance
  engine = "mysql"
  # InvalidParameterCombination: RDS does not support creating a DB instance with the following combination: DBInstanceClass=db.t4g.micro, Engine=mysql, EngineVersion=5.7.41,
  # https://aws.amazon.com/about-aws/whats-new/2021/09/amazon-rds-t4g-mysql-mariadb-postgresql/
  engine_version = "8.0.32"
  # See instance pricing https://aws.amazon.com/rds/mysql/pricing/?pg=pr&loc=2
  instance_class = "db.t4g.micro"

  # mysql -u dbadmin -h <ENDPOINT> -P 3306 -D sample -p
  # name is deprecated, use db_name instead
  db_name  = "sample"
  username = "dbadmin"
  password = data.aws_ssm_parameter.db_password.value
  # parameter_group_name = "default.mysql8.0.32"
  # Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group.
  db_subnet_group_name = aws_db_subnet_group.private_db_subnet.name
  # Error: final_snapshot_identifier is required when skip_final_snapshot is false
  skip_final_snapshot = true

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]
}


###########################
########### EC2 ###########
###########################
resource "aws_instance" "go_api" {
  # https://cloud-images.ubuntu.com/locator/ec2/
  ami = "ami-0afb477ff8d65bb67"
  # creating EC2 Instance: InvalidParameterValue: The architecture 'i386,x86_64' of the specified instance type does not match the architecture 'arm64' of the specified AMI.
  # aws ec2 describe-instance-types --filters Name=processor-info.supported-architecture,Values=arm64 --query "InstanceTypes[*].InstanceType" --output text
  instance_type               = "t4g.micro"
  subnet_id                   = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]
  root_block_device {
    delete_on_termination = true
    # iops                  = 150 # only valid for volume_type io1
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name = "go-api-mysql"
    OS   = "ubuntu"
  }

  depends_on = [aws_security_group.default, aws_key_pair.ec2_key_pair]

  user_data = base64encode(templatefile("user_data.sh", {
    DB_USER = aws_db_instance.mysql_8.username
    DB_PASSWORD_PARAM = data.aws_ssm_parameter.db_password.name
    DB_HOST = aws_db_instance.mysql_8.address
    DB_PORT = aws_security_group_rule.allow_mysql_in.from_port
    DB_NAME = aws_db_instance.mysql_8.db_name
  }))
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2_key_pair"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generates a local file 
# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file 
resource "local_sensitive_file" "tf_key" {
  content              = tls_private_key.rsa.private_key_pem
  file_permission      = "600"
  directory_permission = "700"
  filename             = "${aws_key_pair.ec2_key_pair.key_name}.pem"
}

# Reference an SSM parameter for the password (already created in AWS Console)
data "aws_ssm_parameter" "db_password" {
  name        = "/dev/goapi/db/password"
  # description = "Password for go API MySQL Database"
  # type        = "SecureString"
  # value       = "hpyWhatADay!"  # Update with your desired password
}

# Create an IAM instance profile for the EC2 instance
resource "aws_iam_instance_profile" "instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.instance_role.name
}

# Create an IAM role for the EC2 instance
resource "aws_iam_role" "instance_role" {
  name = "ec2-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the necessary IAM policy to the instance role
resource "aws_iam_role_policy_attachment" "instance_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}