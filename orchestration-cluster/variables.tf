variable "access-key" {
  description = "Access key for AWS Account"
  type        = string
  sensitive   = true
}

variable "secret-key" {
  description = "Secret key for AWS Account"
  type        = string
  sensitive   = true
}

variable "aws-region" {
  description = "region to provision resources in"
  default     = "us-east-1"
  type        = string
}