module "workload" {
  source           = "../../modules/workload"
  env              = "stg"
  vpc_segment      = "1"
  hosted_zone_name = var.hosted_zone_name
}
