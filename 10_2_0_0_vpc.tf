resource "aws_vpc" "vpc_10_2_0_0" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "10.2.0.0/16"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public_10_2_1_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id

  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_10_2_2_0" {
  vpc_id                  = aws_vpc.vpc_10_2_0_0.id
  cidr_block              = "10.2.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_10_2_3_0" {
  vpc_id                  = aws_vpc.vpc_10_2_0_0.id
  cidr_block              = "10.2.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_10_2_101_0" {
  vpc_id            = aws_vpc.vpc_10_2_0_0.id
  cidr_block        = "10.2.101.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_10_2_102_0" {
  vpc_id            = aws_vpc.vpc_10_2_0_0.id
  cidr_block        = "10.2.102.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private_10_2_103_0" {
  vpc_id            = aws_vpc.vpc_10_2_0_0.id
  cidr_block        = "10.2.103.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "gw_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id
}

resource "aws_route_table" "public_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_10_2_0_0.id
  }
}

resource "aws_route_table" "private_10_2_0_0" {
  vpc_id = aws_vpc.vpc_10_2_0_0.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_10_2_0_0.id
  }
}

resource "aws_route_table_association" "sub1_10_2_1_0" {
  route_table_id = aws_route_table.public_10_2_0_0.id
  subnet_id      = aws_subnet.public_10_2_1_0.id
}

resource "aws_route_table_association" "sub2_10_2_2_0" {
  route_table_id = aws_route_table.public_10_2_0_0.id
  subnet_id      = aws_subnet.public_10_2_2_0.id
}

resource "aws_route_table_association" "sub3_10_2_3_0" {
  route_table_id = aws_route_table.public_10_2_0_0.id
  subnet_id      = aws_subnet.public_10_2_3_0.id
}

resource "aws_route_table_association" "private_10_2_0_0" {
  for_each = {
    a : aws_subnet.private_10_2_101_0,
    b : aws_subnet.private_10_2_102_0,
    c : aws_subnet.private_10_2_103_0
  }

  route_table_id = aws_route_table.private_10_2_0_0.id
  subnet_id      = each.value.id
}

resource "aws_eip" "nat_gateway_10_2_0_0" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw_10_2_0_0]
}

resource "aws_nat_gateway" "nat_gateway_10_2_0_0" {
  allocation_id = aws_eip.nat_gateway_10_2_0_0.id
  subnet_id     = aws_subnet.public_10_2_1_0.id
}








