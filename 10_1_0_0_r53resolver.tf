resource "aws_security_group" "r53resolver_endpoint_outbound" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id

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


resource "aws_route53_resolver_endpoint" "outbound_10_1_0_0" {
  direction = "OUTBOUND"
  security_group_ids = [
    aws_security_group.r53resolver_endpoint_outbound.id
  ]
  ip_address {
    subnet_id = aws_subnet.private_10_1_101_0.id
    ip        = "10.1.101.5"
  }

  ip_address {
    subnet_id = aws_subnet.private_10_1_102_0.id
    ip        = "10.1.102.5"
  }

  ip_address {
    subnet_id = aws_subnet.private_10_1_103_0.id
    ip        = "10.1.103.5"
  }
}

resource "aws_route53_resolver_rule" "rule_10_1_0_0_onprem" {

  name = "onprem"

  domain_name = "onprem."
  rule_type = "FORWARD"

  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_10_1_0_0.id

  target_ip {
    ip = aws_network_interface.dns_10_1_0_0.private_ip
  }
}

resource "aws_route53_resolver_rule_association" "rule_10_1_0_0_onprem" {
  for_each = {
    "10.1.0.0": aws_vpc.vpc_10_1_0_0,
    "10.2.0.0": aws_vpc.vpc_10_2_0_0,
  }

  resolver_rule_id = aws_route53_resolver_rule.rule_10_1_0_0_onprem.id
  vpc_id = each.value.id
}