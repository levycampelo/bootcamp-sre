// criar bucket
terraform {
  backend "s3"{
    bucket = "bootcamp-tf-state"
    region = "us-east-1"
    key = "infra/network.tfstate"
  }
}

// chamar modules network
module "network" {
  source = "./modules/network"
  vpc_name = "bootcamp-sre-prod"
  vpc_cidr = "10.255.0.0/16"
  subnet_publica-1_cidr = "10.255.10.0/24"
  subnet_publica-1_name = "subnet_publica-1"
  subnet_publica-2_cidr = "10.255.20.0/24"
  subnet_publica-2_name = "subnet_publica-2"
  subnet_privada-1_cidr = "10.255.30.0/24"
  subnet_privada-1_name = "subnet_privada-1"
  subnet_privada-2_cidr = "10.255.40.0/24"
  subnet_privada-2_name = "subnet_privada-2"
  wp_alb_name = "wordpress-alb"
  alb_sg_name = "wordpress-alb-sg"
}

module "wordpress" {
  source = "./modules/wordpress"
  vpc_id = module.network.vpc_id
  vpc_cidr = module.network.vpc_cidr
  az = module.network.subnet-publica-1_az
  subnet = module.network.subnet-publica-1
  alb_arn = module.network.alb_arn
  db_subnets = [
    module.network.subnet-publica-1,
    module.network.subnet-publica-2
  ]
  rds_password = var.rds_pass
  depends_on = [ module.network ]
  
}