provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""

}

#VPC Block
resource "aws_vpc" "myvpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

#IGW Block
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc1.id

  tags = {
    Name = "main_igw"
  }
}

resource "aws_vpc" "subnet1" {
  cidr_block = "10.0.0.0/16"
}

#Subnet Block
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.subnet1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet1"
  }
}

#Route Table Block
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.myvpc1.id

  route = []

  tags = {
    Name = "routetable1"
  }
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.subnet1.id
  
  tags = {
    Name = "gw1"
  }
}

# Route Block
resource "aws_route" "route1" {
  route_table_id         = aws_route_table.rt1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw1.id
  depends_on             = [aws_route_table.rt1]
}

# Route Table Association Block
resource "aws_route_table_association" "association1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

# Security Group Block
resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "Allow all inbounds traffic security group"
  vpc_id      = aws_vpc.myvpc1.id

  ingress {
    description      = "Incomming from anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg1"
  }
}

# EC2 Block
resource "aws_instance" "firstEC2" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"

  tags = {
    Name = "EC2UsingTF"
  }
}