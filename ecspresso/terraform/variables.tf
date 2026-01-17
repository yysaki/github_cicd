variable "hosted_zone_name" {
  description = "Route53 Hosted Zone Name"
  type        = string
  default     = "example.com"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "yysaki/github_cicd"
}
