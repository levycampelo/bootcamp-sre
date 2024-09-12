// definir provedor
provider "aws" {
  region = "us-east-1"
}

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
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  subnet_publica-1_cidr = var.subnet_publica-1_cidr
  subnet_publica-1_name = var.subnet_publica-1_name
  subnet_publica-2_cidr = var.subnet_publica-2_cidr
  subnet_publica-2_name = var.subnet_publica-2_name
  subnet_privada-1_cidr = var.subnet_privada-1_cidr
  subnet_privada-1_name = var.subnet_privada-1_name
  subnet_privada-2_cidr = var.subnet_privada-2_cidr
  subnet_privada-2_name = var.subnet_privada-2_name
}