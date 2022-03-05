output "ec2_jumphost" {
  value = module.base_vpc.ec2_jumphost
}

output "ec2_internal" {
  value = module.base_vpc.ec2_internal
}

output "vpc" {
  value = module.base_vpc.vpc
}

output "subnets" {
  value = module.base_vpc.subnets
}