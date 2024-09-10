variable "vpc_name" {
  description = "nome da vpc default"
  default = "bootcamp"
}
variable "vpc_cidr" {
  description = "endereco de rede da vpc"
}
variable "subnet_publica-1_cidr" {}
variable "subnet_publica-1_name" {}
variable "subnet_publica-2_cidr" {}
variable "subnet_publica-2_name" {}

variable "subnet_privada-1_cidr" {}
variable "subnet_privada-1_name" {}
variable "subnet_privada-2_cidr" {}
variable "subnet_privada-2_name" {}
