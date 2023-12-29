#-----datasource to find hosted_zone details-----#

data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}
