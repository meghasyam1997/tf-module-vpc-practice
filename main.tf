resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = merge(var.tags,{Name = "${var.env}-vpc"})
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

  tags = merge(var.tags,{Name = "${var.env}-igw"})
}

resource "aws_eip" "ngw" {
  count = length(lookup(lookup(var.subnets, "public",{} ),"cidr_block",null))
  vpc      = true

  tags = merge(var.tags,{Name = "${var.env}-ngw-${count.index}"})
}

#output "subnets" {
#  value = module.subnets
#}

resource "aws_nat_gateway" "ngw" {
  count = length(lookup(lookup(var.subnets, "public",{} ),"cidr_block",null))
  allocation_id = aws_eip.ngw[count.index].id
  subnet_id     = module.subnets["public"].subnet_ids[count.index]

  tags = merge(var.tags,{Name = "${var.env}-ngw-${count.index}"})
}