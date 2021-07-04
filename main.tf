provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

locals {
  endpoint = "${var.host_name}.${var.domain_name}"
}

resource "aws_acm_certificate" "this" {
  count = var.create_certificate ? 1 : 0

  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
  provider          = aws.us-east-1
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in (var.create_certificate ? aws_acm_certificate.this[0].domain_validation_options : []) : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  ttl             = 60
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  count = var.create_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
  provider                = aws.us-east-1
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = var.origin_domain_name
    origin_id   = var.origin_domain_name

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_protocol_policy = "https-only"
    }
  }

  aliases = [local.endpoint]
  enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id = var.origin_domain_name

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 86400

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }

      headers = [
        "Accept",
        "Accept-Charset",
        "Accept-Encoding",
        "Accept-Datetime",
        "Accept-Language",
        "Authorization",
        "Referer"
      ]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.create_certificate ? aws_acm_certificate.this[0].arn : var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = var.host_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}
