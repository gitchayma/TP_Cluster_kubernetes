terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-3"
  access_key = "AKIA6GYDTEVP374O3PAS"
  secret_key = "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"
}

# Create un VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

# Creer un Subnet:
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "kubernetes"
  }
}

#-------gateway-------#
# créer gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "gateway"
  }
}

#-------Route table-------#
### crée Route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    Name = "Tr:kubernetes"
  }
}

# Ajouter route table par défaut à gateway
resource "aws_route" "example" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
### Associé route table à Subnet  
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# Security Groups
resource "aws_security_group" "kubernetes" {
  name        = "kubernetes"
  description = "Kubernetes security group"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description      = "Allow All"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
  ingress {
    description      = "Allow All"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "K8S SG"
  }
}

# créer une clé ssh:
resource "aws_key_pair" "kubernetes" {
  key_name   = "pairKey"
  public_key = file("./ssh/pairKey.pub")  # Remplacez par votre clé publique
}

# Kubernetes Controllers
resource "aws_instance" "controllers" {
  count = 1  # Vous pouvez ajuster le nombre d'instances ici
  associate_public_ip_address = true
  ami           = "ami-05b5a865c3579bbc4"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.kubernetes.key_name
  subnet_id     = aws_subnet.subnet.id
  security_groups = [aws_security_group.kubernetes.id]

  private_ip = "10.0.1.1${count.index}"

  user_data = <<-EOF
    name=controller-${count.index}
    EOF

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "controller-${count.index}"
  }
}
# Kubernetes Workers
resource "aws_instance" "workers" {
  count = 2  # Vous pouvez ajuster le nombre d'instances ici
  associate_public_ip_address = true
  ami           = "ami-05b5a865c3579bbc4"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.kubernetes.key_name
  subnet_id     = aws_subnet.subnet.id
  security_groups = [aws_security_group.kubernetes.id]

  private_ip = "10.0.1.2${count.index}"

  user_data = <<-EOF
    name=worker-${count.index}|pod-cidr=10.200.${count.index}.0/24
    EOF

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "worker-${count.index}"
  }
}




















