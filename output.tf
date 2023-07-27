output "vpc_id" {
    value = aws_vpc.main.id
}

output "vpc_cird" {
    value = aws_vpc.main.cidr_block
}

output "public_subnets_id" {
    value = aws_subnet.public_subnets[*].id
}

output "private_subnets_id" {
    value = aws_subnet.private_subnets[*].id
}