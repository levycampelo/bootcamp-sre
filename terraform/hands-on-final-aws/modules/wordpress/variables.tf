variable "ec2_sg_name" {
  default = "webserver-sg"
}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "ami" {
  default = "ami-007855ac798b5175e"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "az" {}
variable "subnet" {}
variable "key_pair_name" {
  default = "lab-wordpress"
}

variable "rds_sg_name" {
  default = "wp-rds-sg"
}

variable "db_subnets" {
  type = list
}

variable "db_name" {
  default = "wordpress_db"
}

variable "rds_size" {
  default = "db.t3.micro"
}

variable "rds_username" {
  default = "administrator"
}

variable "rds_password" {
}

variable "alb_arn" {}