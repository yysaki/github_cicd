variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "vpc_segment" {
  description = "VPC Segment"
  type        = string
  default     = "0"
}

variable "hosted_zone_name" {
  description = "Route53 Hosted Zone Name"
  type        = string
  default     = "example.com"
}
