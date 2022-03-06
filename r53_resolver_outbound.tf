resource "aws_security_group" "r53resolver_endpoint_outbound" {
  vpc_id = module.vpc_dns.vpc.id

  tags = {
    Name = "r53resolver_endpoint_outbound"
  }
}

resource "aws_security_group_rule" "r53resolver_endpoint_outbound_egress_dns" {
  security_group_id = aws_security_group.r53resolver_endpoint_outbound.id
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  source_security_group_id = aws_security_group.ec2_dns.id
}

resource "aws_security_group_rule" "r53resolver_endpoint_outbound_ingress_all" {
  security_group_id = aws_security_group.r53resolver_endpoint_outbound.id
  type              = "ingress"
  protocol          = "udp"
  from_port         = 53
  to_port           = 53
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_route53_resolver_endpoint" "outbound" {
  direction = "OUTBOUND"
  security_group_ids = [
    aws_security_group.r53resolver_endpoint_outbound.id
  ]
  ip_address {
    subnet_id = module.vpc_dns.subnets.private["us-east-1a"].id
  }

  ip_address {
    subnet_id = module.vpc_dns.subnets.private["us-east-1b"].id
  }

  ip_address {
    subnet_id = module.vpc_dns.subnets.private["us-east-1c"].id
  }
}
