variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "account_id" {
  type = string
}

variable "datalake_bucket_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
