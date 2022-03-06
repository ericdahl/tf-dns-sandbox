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