variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "availability_zones" {
  type    = list(string)
}

variable "additional_vpc_tags" {
  type    = map(string)
  default = {}
}

variable "additional_private_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "additional_public_subnet_tags" {
  type    = map(string)
  default = {}
}
