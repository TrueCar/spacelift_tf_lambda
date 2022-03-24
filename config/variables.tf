variable "aws_region" {
  type        = string
  description = "The AWS region"
  default     = "us-west-2"
}

variable "credentials_profile" {
  type = string
}

variable "name" {
  type    = string
  default = "spacelift poc"
}

variable "security_group_id" {
  type        = string
  description = "Security group id for lambda functions."
}

variable "subnet_id" {
  type        = string
  description = "Subnet id for lambda functions"
}
