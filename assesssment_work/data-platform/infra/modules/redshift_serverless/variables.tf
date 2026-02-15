variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "admin_username" {
  type = string
}

variable "allowed_cidr" {
  type = string
}

variable "redshift_iam_role_arn" {
  type = string
}
