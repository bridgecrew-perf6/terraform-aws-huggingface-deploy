data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  az_names = data.aws_availability_zones.azs.names
  public_sub_ids = aws_subnet.subnet_public.id
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.vpc.id 
  cidr_block = var.subnet_public_cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public-subnet"
  }
}

resource "aws_internet_gateway" internet_gateway {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.project}-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "eip" {
  vpc = true
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "${var.project}-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.subnet_public.id
  tags = {
    Name = "${var.project}-nat-gateway"
  }
}
  

resource "aws_subnet" "subnet_private" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_private_cidr_block
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project}-private-subnet"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.project}-private-route-table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  subnet_id = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_default_network_acl" "default_network_acl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  subnet_ids = [aws_subnet.subnet_private.id, aws_subnet.subnet_public.id]
  
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.project}-default-default-network-acl"
  }
}

resource "aws_default_security_group" "default_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-default-security-group"
  }
}

