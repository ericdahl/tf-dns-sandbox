resource "aws_route53_zone" "private1" {
  vpc {
    vpc_id = module.vpc_dns.vpc.id
  }

  name = "private1."

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_record" "private1_hello" {
  name    = "hello"
  type    = "TXT"
  zone_id = aws_route53_zone.private1.id
  ttl     = 5
  records = [
    "world"
  ]
}

resource "aws_route53_record" "private1_a" {
  name    = "a"
  type    = "A"
  zone_id = aws_route53_zone.private1.id
  ttl     = 5
  records = [
    "127.0.0.1"
  ]
}

resource "aws_route53_zone_association" "private1" {
  for_each = { for v in module.vpc_workload : v.vpc.cidr_block => v.vpc.id }

  zone_id = aws_route53_zone.private1.id
  vpc_id = each.value
}