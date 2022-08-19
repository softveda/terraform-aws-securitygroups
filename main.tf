
# https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html#vpc-limits-security-groups

locals {
  # Read json files and append them into a single directory
  inputfiles = [for f in fileset(path.module, "JsonObjects/*_objects.json") : jsondecode(file(f))]

  security_group_resources = merge(local.inputfiles...)
}

# For test
module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "4.11.0"

  create = true

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["10.100.0.0/32", "10.100.0.1/32"]
}

# create security group
module "appid_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "4.11.0"

  create = false

  for_each            = local.security_group_resources
  name                = each.key
  description         = "Security group from Json"
  vpc_id              = var.vpc_id
  ingress_cidr_blocks = lookup(each.value, "ipaddr", [])
}
