resource "aws_route53_zone" "onprem" {
  vpc {
    vpc_id = module.vpc_dns.vpc.id
  }

  name = "onprem."

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_record" "onprem_hello" {
  name    = "hello"
  type    = "TXT"
  zone_id = aws_route53_zone.onprem.id
  ttl     = 5
  records = [
    "aws"
  ]
}

resource "aws_route53_record" "onprem_a" {
  name    = "a"
  type    = "A"
  zone_id = aws_route53_zone.onprem.id
  ttl     = 5
  records = [
    "127.222.222.222"
  ]
}

resource "aws_route53_zone_association" "onprem" {
  for_each = { for v in module.vpc_workload : v.vpc.cidr_block => v.vpc.id }

  zone_id = aws_route53_zone.onprem.id
  vpc_id  = each.value
}