
resource "aws_security_group" "dns_10_1_0_0" {
  vpc_id = aws_vpc.vpc_10_1_0_0.id

  tags = {
    Name = "dns_10_1_0_0"
  }
}

resource "aws_security_group_rule" "dns_10_1_0_0_ingress_53" {
  security_group_id = aws_security_group.dns_10_1_0_0.id
  type              = "ingress"
  protocol          = "udp"
  from_port         = 53
  to_port           = 53
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "dns_10_1_0_0_ingress_22_jumphost" {
  security_group_id        = aws_security_group.dns_10_1_0_0.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = aws_security_group.jumphost_10_1_0_0.id
}

resource "aws_security_group_rule" "dns_10_1_0_0_egress_all" {
  security_group_id = aws_security_group.dns_10_1_0_0.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "dns_10_1_0_0" {
  ami = data.aws_ssm_parameter.amazon_linux_2.value

  instance_type = "t2.small"
  subnet_id     = aws_subnet.private_10_1_101_0.id

  vpc_security_group_ids = [
    aws_security_group.dns_10_1_0_0.id,
  ]

  key_name = aws_key_pair.default.key_name

  user_data = <<EOF
#!/usr/bin/env bash

echo hello world

yum install -y dnsmasq

EOF

}

output "dns" {
  value = {
    instance_id : aws_instance.dns_10_1_0_0.id
    private_ip : aws_instance.dns_10_1_0_0.private_ip
  }
}

