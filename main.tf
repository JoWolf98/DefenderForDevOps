############################################
# Provider Configuration
############################################
provider "aws" {
  region = "us-east-1" # Change to your preferred AWS region
}

############################################
# Key Pair (for SSH access)
############################################
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-public-key"
  public_key = file("~/.ssh/id_rsa.pub") # Ensure this file exists
}

############################################
# VPC
############################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "public-vpc"
  }
}

############################################
# Internet Gateway
############################################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-igw"
  }
}

############################################
# Public Subnet
############################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "public-subnet"
  }
}

############################################
# Route Table for Public Subnet
############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

############################################
# Security Group (Allow SSH & HTTP)
############################################
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Open to all
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

############################################
# EC2 Instance
############################################
resource "aws_instance" "public_ec2" {
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (us-east-1)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  key_name                    = aws_key_pair.ec2_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "public-ec2"
  }
}
