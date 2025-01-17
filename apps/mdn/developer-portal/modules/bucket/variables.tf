variable "region" {
  default = "us-west-2"
}

variable "environment" {}

variable "bucket_name" {}

variable "eks_worker_role_arn" {}

variable "bucket_acl" {
  default = "public-read"
}
