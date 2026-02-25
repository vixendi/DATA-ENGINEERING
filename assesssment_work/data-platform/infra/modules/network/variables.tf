variable "name" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.50.0.0/24", "10.50.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.50.10.0/24", "10.50.11.0/24"]
}
