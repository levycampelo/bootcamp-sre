# criar um bucket s3
resource "aws_s3_bucket" "bootcamp-sre" {
  bucket = "bootcamp-sre" 
 
  tags = {
    Name = "bootcamp-sre"
    Environment = "prod"
  }
}

# criar a nova vpc
resource "aws_vpc" "bootcamp-sre" {
  cidr_block = "192.168.250.0/24"

  tags = {
    Name = "bootcamp-sre"
  }
}

# criar uma subnet-public 
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.bootcamp-sre.id
  cidr_block        = "192.168.250.0/27" 
  availability_zone = "us-east-1a"
    
  tags = {
    Name = "public-subnet"
  }
}

# criar uma subnet-privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.bootcamp-sre.id
  cidr_block        = "192.168.250.32/27" 
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

# criar uma subnet-database
resource "aws_subnet" "database_subnet" {
  vpc_id            = aws_vpc.bootcamp-sre.id
  cidr_block        = "192.168.250.64/27"  
  availability_zone = "us-east-1a"

  tags = {
    Name = "database-subnet"
  }
}
# criar o internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.bootcamp-sre.id

  tags = {
    Name = "my-igw"
  }
}

# routing-table subnet-publica
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

# associar routing-table subnet-publica
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# criar o nat gateway subnet-publica
resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "my-nat"
  }
}

# associar ip elastico
resource "aws_eip" "my_eip" {
  domain = "vpc"
}

# routing-table subnet-privada
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

# associar routing-table subnet-privada
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# routing-table subnet-database
resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.bootcamp-sre.id

  tags = {
    Name = "database-route-table"
  }
}

#  associar routing-table subnet-database
resource "aws_route_table_association" "database_subnet_association" {
  subnet_id      = aws_subnet.database_subnet.id
  route_table_id = aws_route_table.database_route_table.id
}

# criar um ec2 teste com ami amazonlinux com ssm
resource "aws_instance" "back-end" {
  ami           = "ami-066784287e358dad1" 
  instance_type = "t2.micro" 
  subnet_id = aws_subnet.private_subnet.id

  tags = {
    Name = "bootcamp-sre"
  }
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}

# criar uma iam role para acesso ssm
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

# associar a iam role ssm
resource "aws_iam_role_policy_attachment" "ssm_role_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# criar uma iam instance para associar a ec2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

#### Teste do ASG
# criar o sg para o loadbalance
resource "aws_security_group" "lb_sg" {
  name   = "lb_sg"
  vpc_id = aws_vpc.bootcamp-sre.id 

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb-sg"
  }
}

# criar o tg para o NLB
resource "aws_lb_target_group" "target_group" {
  name     = "bootcamp-sre-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.bootcamp-sre.id

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = {
    Name = "bootcamp-sre-tg"
  }
}

# criar o nlb
resource "aws_lb" "nlb" {
  name               = "bootcamp-sre-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet.id]

  tags = {
    Name = "bootcamp-sre-nlb"
  }
}

# adicionar o listener
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# launch ec2 modelo
resource "aws_launch_template" "ec2_template" {
  name_prefix   = "bootcamp-sre-template"
  image_id      = "ami-066784287e358dad1" # Amazon Linux 2
  instance_type = "t2.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "bootcamp-sre-ec2"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.lb_sg.id]
    subnet_id                   = aws_subnet.public_subnet.id
  }
}

# asg
resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.public_subnet.id]
  target_group_arns    = [aws_lb_target_group.target_group.arn]
  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "bootcamp-sre-ec2"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  force_delete = true
}

# associar nlb para asg
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn   = aws_lb_target_group.target_group.arn
}

