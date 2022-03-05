output "ec2_dns" {
  value = {
    instance_id : aws_instance.dns.id
    private_ip : aws_instance.dns.private_ip
  }
}

output "dns" {
  value = module.vpc_dns
}

output "workload" {
  value = module.vpc_workload
}