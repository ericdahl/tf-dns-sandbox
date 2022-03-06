resource "aws_route53_resolver_rule" "onprem" {

  name = "onprem"

  domain_name = "onprem."
  rule_type   = "FORWARD"

  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  target_ip {
    ip = aws_network_interface.dns.private_ip
  }
}

resource "aws_route53_resolver_rule_association" "onprem" {
  for_each = { for v in local.all_vpcs_map : v.vpc.cidr_block => v.vpc.id }

  resolver_rule_id = aws_route53_resolver_rule.onprem.id
  vpc_id           = each.value
}