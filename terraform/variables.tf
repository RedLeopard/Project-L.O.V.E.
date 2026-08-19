variable "aws_region" {
  description = "AWS region for Project L.O.V.E."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ProjectLOVE"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "605383993555"
}
