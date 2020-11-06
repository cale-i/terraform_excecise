###########################################
# Route53
###########################################

data "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = data.aws_route53_zone.main.name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

output "domain_name" {
  value = aws_route53_record.main.name
}

###########################################
# ACM
# HTTPS時コメントアウト外す
###########################################

# resource "aws_acm_certificate" "main" {
#   domain_name               = aws_route53_record.main.name
#   subject_alternative_names = []    # ドメイン名を追加する場合に設定。eg.["test.example.com"]
#   validation_method         = "DNS" # ドメイン所有権の検証方法 EMAIL or DNS

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "certificate" {
#   # ver3.0以降ではlist形式からset形式に変更されているため、for/for_eachを使用する
#   # name    = aws_acm_certificate.main.domain_validation_options[0].resource_record_name
#   # type    = aws_acm_certificate.main.domain_validation_options[0].resource_record_type
#   # records = [aws_acm_certificate.main.domain_validation_options[0].resource_record_value]
#   for_each = {
#     for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   }
#   allow_overwrite = true
#   name            = each.value.name
#   type            = each.value.type
#   records         = [each.value.record]

#   ttl        = 60
#   depends_on = [aws_acm_certificate.main]
#   zone_id    = data.aws_route53_zone.main.id

# }

# # 検証の待機
# # apply時にSSL証明書の検証が完了するまで待機する

# resource "aws_acm_certificate_validation" "main" {
#   certificate_arn         = aws_acm_certificate.main.arn
#   validation_record_fqdns = [for record in aws_route53_record.certificate : record.fqdn]
# }

