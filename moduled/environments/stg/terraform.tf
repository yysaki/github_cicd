terraform {
  backend "s3" {
    # bucket       = "example-com" # -backend-config="bucket=example-com"
    key          = "moduled/stg/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.28.0"
    }
  }

  required_version = "= 1.14.3"
}
