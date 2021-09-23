resource "aws_route53_zone" "private1" {
  vpc {
    vpc_id = aws_vpc.vpc_10_1_0_0.id
  }

  name = "private1."
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
  for_each = {
    "10.2.0.0" : aws_vpc.vpc_10_2_0_0.id
  }

  zone_id = aws_route53_zone.private1.id
  vpc_id = each.value

}