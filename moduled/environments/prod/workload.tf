module "workload" {
  source           = "../../modules/workload"
  env              = "prod"
  vpc_segment      = "0"
  hosted_zone_name = var.hosted_zone_name
}
