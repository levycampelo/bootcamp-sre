// criar a ec2
resource "aws_security_group" "ec2-sg" {
  name = var.ec2_sg_name
  description = "permitir todo trafego de entrada para vpc"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]

  }
  egress = [{
    from_port = 0
    to_port = 0
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = []
    prefix_list_ids   = []
    security_groups   = []
    self              = false
    description       = "Allow all outbound traffic"
    }]
  tags = {
    Terraformed = "true"
  }
}

resource "aws_instance" "webserver" {
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = var.az
  subnet_id = var.subnet
  associate_public_ip_address = true
  key_name = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  root_block_device {
    volume_size = "10"
  }
  tags = {
    Terraformed = "true"
    webserver = "true"
  }
  
}

//criar o rds
resource "aws_security_group" "rds-sg" {
  name = var.rds_sg_name
  description = "permitir todo trafego de entrada para vpc"
  vpc_id = var.vpc_id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]

  }
  egress = [{
    from_port = 0
    to_port = 0
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = []
    prefix_list_ids   = []
    security_groups   = []
    self              = false
    description       = "Allow all outbound traffic"
    }]
  tags = {
    Terraformed = "true"
  }
}

resource "aws_db_subnet_group" "default" {
  name = "wp-default"
  subnet_ids = var.db_subnets
  tags = {
    Name = "DB subnet group"
  }
  
}

resource "aws_db_instance" "rds_mysql" {
  allocated_storage = 10
  identifier = "wp-database"
  publicly_accessible = true
  engine = "mysql"
  engine_version = "8.0.35"
  instance_class = var.rds_size
  username = var.rds_username
  password = var.rds_password
  parameter_group_name = "default.mysql8"
  skip_final_snapshot = true
  apply_immediately = true
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_subnet_group_name = aws_db_subnet_group.default.name
  tags = {
    Terraformed = "true"
  }
}

//target group
resource "aws_lb_target_group" "webserver" {
  name = "webserver-wp"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
}

resource "aws_lb_listener" "front-end" {
  load_balancer_arn = var.alb_arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"    
    target_group_arn = aws_lb_target_group.webserver.arn
  }
  
}

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.webserver.arn
  target_id = aws_instance.webserver.id
  port = 80
  
}