output "alb_arn" {
  value = aws_lb.wp-alb.arn
  
}

output "vpc_id" {
  value = aws_vpc.bootcamp.id
}

output "vpc_cidr" {
  value = aws_vpc.bootcamp.cidr_block
}

output "subnet-publica-1" {
  value = aws_subnet.subnet-publica-1.id
}

output "subnet-publica-2" {
  value = aws_subnet.subnet-publica-2.id
}

// caso de erro remover
output "subnet-publica-1_az" {
  value = aws_subnet.subnet-publica-1.availability_zone
}

