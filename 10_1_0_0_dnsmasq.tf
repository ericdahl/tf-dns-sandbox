
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

resource "aws_network_interface" "dns_10_1_0_0" {
  subnet_id = aws_subnet.private_10_1_101_0.id
  private_ips = ["10.1.101.111"]
  tags = {
    Name = "dns_10_1_0_0"
  }

  security_groups = [
    aws_security_group.dns_10_1_0_0.id,
  ]
}

resource "aws_instance" "dns_10_1_0_0" {
  ami = data.aws_ssm_parameter.amazon_linux_2.value

  instance_type = "t2.small"
  key_name = aws_key_pair.default.key_name

  network_interface {
    network_interface_id = aws_network_interface.dns_10_1_0_0.id
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
    Name = "dns_10_1_0_0"
  }
}

output "dns_10_1_0_0" {
  value = {
    instance_id : aws_instance.dns_10_1_0_0.id
    private_ip : aws_instance.dns_10_1_0_0.private_ip
  }
}

