resource "aws_security_group" "r53resolver_endpoint_inbound" {
  vpc_id = module.vpc_dns.vpc.id

  tags = {
    Name = "r53resolver_endpoint_inbound"
  }
}

resource "aws_security_group_rule" "r53resolver_endpoint_inbound_ingress_dns_vpc" {
  security_group_id = aws_security_group.r53resolver_endpoint_inbound.id
  type              = "ingress"
  protocol          = "udp"
  from_port         = 53
  to_port           = 53
  cidr_blocks       = [module.vpc_dns.vpc.cidr_block]
}


resource "aws_route53_resolver_endpoint" "inbound" {
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.r53resolver_endpoint_inbound.id
  ]

  ip_address {
    subnet_id = module.vpc_dns.subnets.public["us-east-1a"].id
  }

  ip_address {
    subnet_id = module.vpc_dns.subnets.public["us-east-1b"].id
  }

  ip_address {
    subnet_id = module.vpc_dns.subnets.public["us-east-1c"].id
  }
}