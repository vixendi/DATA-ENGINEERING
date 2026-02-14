variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "datalake_bucket_name" {
  type = string
}

variable "glue_role_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
