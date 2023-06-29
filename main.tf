resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge(var.tags, {Name = "${var.env}-vpc"})
}

module "subnets" {
  source = "./subnets"

  for_each = var.subnets
  vpc_id = aws_vpc.main.id
  cidr_block = each.value["cidr_block"]
  name = each.value["name"]
  azs = each.value["azs"]

  env = var.env
  tags = var.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {Name = "${var.env}-igw"})
}

resource "aws_eip" "lb" {
  count = length(lookup(lookup(var.subnets, "public",{}),"cidr_block",null ))
  vpc      = true
  tags = merge(var.tags, {Name = "${var.env}-ngw"})
}

#resource "aws_nat_gateway" "ngw" {
#
#  allocation_id = aws_eip.example.id
#  subnet_id     = aws_subnet.example.id
#
#  tags = {
#    Name = "gw NAT"
#  }
#}