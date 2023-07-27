#####################################################
#  Terraform VPC Module
#
# Provision
#
# 1. VPC
# 2. Public Subnets
# 3. Private Subnets
# 4. NAT GTW, EIP, Route Tables and Internet GTW
#######################################################

data "aws_availability_zones" "current" {}

#=======================VPC Block ============================

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    tags       = merge(var.tags, {Name = "${var.env}-vpc"})
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags   =  merge(var.tags, {Name = "${var.env}-igw"})
}

#===============VPC Public Subnets and Route table=====================

resource "aws_subnet" "public_subnets" {
    count                   = length(var.public_subnet_cidrs)
    vpc_id                  = aws_vpc.main.id
    cidr_block              = element(var.public_subnet_cidrs, count.index)
    map_public_ip_on_launch = true
    tags                    = merge(var.tags, {Name = "${var.env}-public-${count.index + 1}" } )
}

resource "aws_route_table" "public_subnet-rt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = merge(var.tags, {Name = "${var.env}-route-public-subnets"} )
}

resource "aws_route_table_association" "public_routes" {
    count          = length(aws_subnet.public_subnets[*].id)
    route_table_id = aws_route_table.public_subnet-rt.id
    subnet_id      = aws_subnet.public_subnets[count.index].id
}

#=====================VPC Private Subnets and Route =========================

resource "aws_subnet" "private_subnets" {
    vpc_id            = aws_vpc.main.id
    count             = length(var.private_subnet_cidrs)
    cidr_block        = element(var.private_subnet_cidrs, count.index)
    availability_zone = data.aws_availability_zones.current.names[count.index]
    tags              = merge(var.tags, {Name = "${var.env}-private-${count.index +1}" } )
}

resource "aws_route_table" "private_subnet-rt" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gtw[count.index].id
    }
    tags = merge(var.tags, {Name = "${var.env}-route-private-subnet-${count.index +1}" } )
}

resource "aws_route_table_association" "private-routes" {
    count          = length(aws_subnet.private_subnets[*].id)
    route_table_id = aws_route_table.private_subnet-rt[count.index].id
    subnet_id      = aws_subnet.private_subnets[count.index].id
}


#===================VPC NAT Gateway and Elastic IP=============================

resource "aws_eip" "nat_eip" {
    count = length(var.private_subnet_cidrs)
    tags  = merge(var.tags, {Name = "${var.env}-nat-gtw-eip${count.index +1}" } ) 
}

resource "aws_nat_gateway" "nat-gtw" {
    count         = length(var.private_subnet_cidrs)
    allocation_id = aws_eip.nat_eip[count.index].id
    subnet_id     = aws_subnet.private_subnets[count.index].id
    tags          = merge(var.tags, {Name = "${var.env}-nat-gtw-${count.index +1}" } )
}