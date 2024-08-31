# bucket s3
resource "aws_s3_bucket" "bootcamp-sre" {
  bucket = "bootcamp-sre" 
 
  tags = {
    Name = "bootcamp-sre"
    Environment = "prod"
  }
}

# vpc 
resource "aws_vpc" "bootcamp-sre" {
  cidr_block = "192.168.250.0/24"

  tags = {
    Name = "bootcamp-sre"
  }
}

# subnet-public 
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.bootcamp-sre.id
  cidr_block        = "192.168.250.0/27" 
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

# subnet-privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.bootcamp-sre.id
  cidr_block        = "192.168.250.32/27" 
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

# subnet-database
resource "aws_subnet" "database_subnet" {
  vpc_id            = aws_vpc.bootcamp-sre.id
  cidr_block        = "192.168.250.64/27"  
  availability_zone = "us-east-1a"

  tags = {
    Name = "database-subnet"
  }
}
# Internet Gateway 
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.bootcamp-sre.id

  tags = {
    Name = "my-igw"
  }
}

# routing-table subrede publica
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.bootcamp-sre.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# associar routing-table subrede publica
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# NAT Gateway subrede publica
resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "my-nat"
  }
}

# Elastic IP NAT Gateway
resource "aws_eip" "my_eip" {
  domain = "vpc"
}

# routing-table subrede privada
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.bootcamp-sre.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# associar routing-table subrede privada
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Criar uma Tabela de Rotas para a sub-rede de banco de dados
resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.bootcamp-sre.id

  tags = {
    Name = "database-route-table"
  }
}

# Associar a Tabela de Rotas à sub-rede de banco de dados
resource "aws_route_table_association" "database_subnet_association" {
  subnet_id      = aws_subnet.database_subnet.id
  route_table_id = aws_route_table.database_route_table.id
}

# EC2
resource "aws_instance" "back-end" {
  ami           = "ami-066784287e358dad1" 
  instance_type = "t2.micro" 
  subnet_id = aws_subnet.private_subnet.id

  tags = {
    Name = "bootcamp-sre"
  }
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}

# Criar um IAM Role e uma política para o SSM
resource "aws_iam_role" "ssm_role" {
  name = "SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Anexar a política gerenciada do SSM ao IAM Role
resource "aws_iam_role_policy_attachment" "ssm_role_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Criar um IAM Instance Profile para associar ao EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}


