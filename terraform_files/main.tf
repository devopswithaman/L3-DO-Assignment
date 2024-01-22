provider "aws" {
  region = "us-east-1"
}

variable "vpc-name" {
    default = "Jenkins-vpc"
}

variable "igw-name" {
    default = "Jenkins-igw"
}

variable "rt-name" {
    default = "Jenkins-route-table"
}

variable "subnet-name" {
    default = "Jenkins-subnet"
}

variable "sg-name" {
    default = "Jenkins-sg"
}

variable "instance-name" {
    default = "Jenkins-server"
}

variable "key-name" {
    default = "demo-admin"
}

variable "iam-role" {
    default = "Jenkins-iam-role"
} 

variable "ami_id" {
    default = "ami-0c7217cdde317cfec"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.vpc-name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw-name
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet-name
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.rt-name
  }
}

resource "aws_route_table_association" "rt-association" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.public-subnet.id
}

resource "aws_security_group" "security-group" {
  vpc_id      = aws_vpc.vpc.id
  description = "Allowing Jenkins, Sonarqube, SSH Access"

  ingress = [
    for port in [22, 8080, 9000, 9090, 80] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg-name
  }
}

resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  instance_type          = "t2.large"
  key_name               = var.key-name
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.security-group.id]
  iam_instance_profile   = aws_iam_instance_profile.instance-profile.name
  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = var.instance-name
  }
}

resource "aws_iam_instance_profile" "instance-profile" {
  name = "Jenkins-instance-profile"
  role = aws_iam_role.iam-role.name
}

resource "aws_iam_role_policy_attachment" "iam-policy" {
  role        = aws_iam_role.iam-role.name
  policy_arn  = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "iam-role" {
  name               = var.iam-role
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
