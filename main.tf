provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

# Create a VPC with tags
resource "aws_vpc" "main" {
  cidr_block = "11.0.0.0/16" # Replace with your desired VPC CIDR block

  tags = {
    Name = "MyVPC-1"
  }
}

# Create a subnet in the VPC with tags
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "11.0.1.0/24" # Replace with your desired subnet CIDR block

  tags = {
    Name = "MySubnet-1"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MyInternetGateway-1"
  }
}

# Create a route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "MyRouteTable-1"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Create a security group for the EC2 instance
resource "aws_security_group" "jenkins_sg1" {
  name        = "jenkins_security_group1"
  description = "Security group for Jenkins EC2 instance"

  ingress {
    from_port   = 22 # SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080 # Jenkins port
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main.id
}

# Create an Elastic IP for the Jenkins instance
resource "aws_eip" "jenkins_eip1" {
  instance = aws_instance.jenkins_instance.id
}

# Create an EC2 instance with Jenkins installed
resource "aws_instance" "jenkins_instance1" {
  ami           = "ami-0546bd5416f7138ed" # Jenkins ubuntu in us-east-1. Replace with the appropriate AMI for your region.
  instance_type = "t2.micro"              # Change instance type as needed
  key_name      = "andi"                  # Replace with the name of your key pair created on AWS

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.main.id

  tags = {
    Name = "JenkinsInstance1"
  }

  user_data = <<-EOF
              #!/bin/bash
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
              /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
              https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
              /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update
              sudo apt-get install jenkins
              EOF
}
