// criar a vpc
resource "aws_vpc" "bootcamp" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name,
    Terraformed = "true" 
  }
}

// criar as subnets
resource "aws_subnet" "subnet-publica-1"{
  vpc_id = aws_vpc.bootcamp.id
  cidr_block = var.subnet_publica-1_cidr
  tags = {
    Name = var.subnet_publica-1_name,
    Terraformed = "true"
  }
  depends_on = [
    aws_vpc.bootcamp
  ]
}

resource "aws_subnet" "subnet-publica-2"{
  vpc_id = aws_vpc.bootcamp.id
  cidr_block = var.subnet_publica-2_cidr
  tags = {
    Name = var.subnet_publica-2_name,
    Terraformed = "true"
  }
   depends_on = [
    aws_vpc.bootcamp
  ]
}

resource "aws_subnet" "subnet-privada-1"{
  vpc_id = aws_vpc.bootcamp.id
  cidr_block = var.subnet_privada-1_cidr
  tags = {
    Name = var.subnet_privada-1_name,
    Terraformed = "true"
  }
   depends_on = [
    aws_vpc.bootcamp
  ]
}

resource "aws_subnet" "subnet-privada-2"{
  vpc_id = aws_vpc.bootcamp.id
  cidr_block = var.subnet_privada-2_cidr
  tags = {
    Name = var.subnet_privada-2_name,
    Terraformed = "true"
  }
   depends_on = [
    aws_vpc.bootcamp
  ]
}

//criar internet gateway
resource "aws_internet_gateway" "internet-gw"{
  vpc_id = aws_vpc.bootcamp.id
  tags = {
    Name = "internet-gw"
    Terraformed = "true"
  }
   depends_on = [
    aws_vpc.bootcamp
  ]
}

//criar ip elastico
resource "aws_eip" "eip-nat-gw-1"{
  domain = "vpc"
  tags = {
    Terraformed = true
  }
   depends_on = [
    aws_vpc.bootcamp,
    aws_internet_gateway.internet-gw
  ]
}

resource "aws_eip" "eip-nat-gw-2"{
  domain = "vpc"
  tags = {
    Terraformed = true
  }
  depends_on = [
    aws_vpc.bootcamp,
    aws_internet_gateway.internet-gw
  ]
}

//criar os nat-gw
resource "aws_nat_gateway" "nat-gw-1" {
    allocation_id = aws_eip.eip-nat-gw-1.id
    subnet_id = aws_subnet.subnet-publica-1.id 
    depends_on = [
    aws_vpc.bootcamp,
    aws_internet_gateway.internet-gw,
    aws_eip.eip-nat-gw-1
  ]
}

resource "aws_nat_gateway" "nat-gw-2" {
    allocation_id = aws_eip.eip-nat-gw-2.id
    subnet_id = aws_subnet.subnet-publica-2.id
     depends_on = [
    aws_vpc.bootcamp,
    aws_internet_gateway.internet-gw,
    aws_eip.eip-nat-gw-2
  ]
}

//tabela de roteamento
resource "aws_route_table" "publica" {
    vpc_id = aws_vpc.bootcamp.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.internet-gw.id
  }
  tags = {
    Name = "rtb-publica"
  }
}

resource "aws_route_table" "privada-1" {
  vpc_id = aws_vpc.bootcamp.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-1.id
  }
  tags = {
    Name = "rtb-privada-1"
  }
   depends_on = [
    aws_vpc.bootcamp,
    aws_internet_gateway.internet-gw
  ]
}

resource "aws_route_table" "privada-2" {
  vpc_id = aws_vpc.bootcamp.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-2.id
  }
  tags = {
    Name = "rtb-privada-2"
  }
   depends_on = [
    aws_vpc.bootcamp,
    aws_internet_gateway.internet-gw
  ]
}


//criar associacao entre routing table e subnets
resource "aws_route_table_association" "rtb-publica-1" {
  subnet_id = aws_subnet.subnet-publica-1.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table_association" "rtb-publica-2" {
  subnet_id = aws_subnet.subnet-publica-2.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table_association" "rtb-privada-1" {
  subnet_id = aws_subnet.subnet-privada-1.id
  route_table_id = aws_route_table.publica.id
}
resource "aws_route_table_association" "rtb-privada-2" {
  subnet_id = aws_subnet.subnet-privada-2.id
  route_table_id = aws_route_table.publica.id
}


