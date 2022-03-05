resource "aws_security_group" "ec2_dns" {
  vpc_id = module.vpc_dns.vpc.id

  tags = {
    Name = "dns_10_1_0_0"
  }
}

resource "aws_security_group_rule" "ec2_dns_ingress_53" {
  security_group_id = aws_security_group.ec2_dns.id
  type              = "ingress"
  protocol          = "udp"
  from_port         = 53
  to_port           = 53
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ec2_dns_ingress_22_jumphost" {
  security_group_id        = aws_security_group.ec2_dns.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = module.vpc_dns.ec2_jumphost.security_group_id
}

resource "aws_security_group_rule" "ec2_dns_egress_all" {
  security_group_id = aws_security_group.ec2_dns.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_network_interface" "dns" {
  subnet_id = module.vpc_dns.subnets.private["us-east-1a"].id
  tags = {
    Name = "dns_10_1_0_0"
  }

  security_groups = [
    aws_security_group.ec2_dns.id,
  ]
}

resource "aws_instance" "dns" {
  ami = data.aws_ssm_parameter.amazon_linux_2.value

  instance_type = "t2.small"
  key_name      = aws_key_pair.default.key_name

  network_interface {
    network_interface_id = aws_network_interface.dns.id
    device_index         = 0
  }

  user_data = <<EOF
#!/usr/bin/env bash

echo hello world

yum install -y dnsmasq

# listen on all interfaces/IPs
sed -i 's/interface=lo/#interface=lo/' /etc/dnsmasq.conf

# simulate being some on-prem DNS host
echo 'address=/a.onprem/1.2.3.4' >> /etc/dnsmasq.conf

chkconfig dnsmasq on
systemctl start dnsmasq

EOF

  tags = {
    Name = "dns"
  }
}


