locals {
  azs = { for idx, az in slice(data.aws_availability_zones.available.names, 0, 2) : az => idx }
}

resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "example"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  for_each = local.azs

  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.${each.value * 16}.0/20"
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.azs

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  for_each = local.azs

  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.${each.value * 16 + 128}.0/20"
  availability_zone = each.key

  tags = {
    Name = "private-${each.key}"
  }
}

resource "aws_route_table" "private" {
  for_each = local.azs

  vpc_id = aws_vpc.example.id
}

resource "aws_route" "private" {
  for_each = local.azs

  route_table_id         = aws_route_table.private[each.key].id
  nat_gateway_id         = aws_nat_gateway.nat_gateway[each.key].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_eip" "nat_gateway" {
  for_each = local.azs

  domain = "vpc"

  tags = {
    Name = "nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.example]
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = local.azs

  allocation_id = aws_eip.nat_gateway[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "nat-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = local.azs

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
