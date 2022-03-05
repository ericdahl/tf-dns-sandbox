resource "aws_security_group" "r53resolver_endpoint_outbound" {
  vpc_id = module.vpc_dns.vpc.id

  tags = {
    Name = "r53resolver_endpoint_outbound"
  }
}

resource "aws_security_group_rule" "r53resolver_endpoint_outbound_egress_all" {
  security_group_id = aws_security_group.r53resolver_endpoint_outbound.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "r53resolver_endpoint_outbound_ingress_all" {
  security_group_id = aws_security_group.r53resolver_endpoint_outbound.id
  type              = "ingress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_route53_resolver_endpoint" "outbound" {
  direction = "OUTBOUND"
  security_group_ids = [
    aws_security_group.r53resolver_endpoint_outbound.id
  ]
  ip_address {
    subnet_id = module.vpc_dns.subnets.private["us-east-1a"].id
    #    ip        = "10.1.101.5"
  }

  ip_address {
    subnet_id = module.vpc_dns.subnets.private["us-east-1b"].id
    #    ip        = "10.1.102.5"
  }

  ip_address {
    subnet_id = module.vpc_dns.subnets.private["us-east-1c"].id
    #    ip        = "10.1.103.5"
  }
}

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

  for_each = { for v in merge(module.vpc_workload, { (module.vpc_dns.vpc.cidr_block) = module.vpc_dns }) : v.vpc.cidr_block => v.vpc.id }

  resolver_rule_id = aws_route53_resolver_rule.onprem.id
  vpc_id           = each.value
}

resource "aws_cloudwatch_log_group" "route53_resolver_query_log" {
  name = "route53-resolver-querylog"
}

resource "aws_route53_resolver_query_log_config" "default" {
  destination_arn = aws_cloudwatch_log_group.route53_resolver_query_log.arn
  name            = "tf-dns-sandbox"
}

resource "aws_route53_resolver_query_log_config_association" "default" {
  for_each = { for v in merge(module.vpc_workload, { (module.vpc_dns.vpc.cidr_block) = module.vpc_dns }) : v.vpc.cidr_block => v.vpc.id }

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.default.id
  resource_id                  = each.value
}