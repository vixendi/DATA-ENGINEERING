variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "airflow_bucket_name" {
  type = string
}

variable "dag_s3_path" {
  type    = string
  default = "dags"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "environment_class" {
  type    = string
  default = "mw1.micro"
}

variable "min_workers" {
  type    = number
  default = 1
}

variable "max_workers" {
  type    = number
  default = 1
}

variable "schedulers" {
  type    = number
  default = 1
}

variable "webserver_access_mode" {
  type    = string
  default = "PUBLIC_ONLY"
}

variable "web_ui_allowed_cidr" {
  type = string
}

variable "airflow_version" {
  type    = string
  default = "2.11.0"
}
