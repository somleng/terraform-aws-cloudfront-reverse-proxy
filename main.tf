provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

locals {
  endpoint = "${var.host_name}.${var.domain_name}"
}

resource "aws_acm_certificate" "this" {
  count = var.create_certificate ? 1 : 0

  domain_name       = local.endpoint
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

resource "aws_cloudfront_cache_policy" "this" {
  name    = replace("${local.endpoint}-proxy", ".", "-")

  default_ttl = 0
  max_ttl     = 1
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Authorization",
          "Accept-Encoding"
        ]
      }
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "this" {
  name    = replace("${local.endpoint}-proxy", ".", "-")

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = [
        "Accept",
        "Accept-Charset",
        "Accept-Language",
        "Accept-Datetime",
        "Origin",
        "Referer",
        "Access-Control-Request-Method",
        "Access-Control-Request-Headers"
      ]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = var.origin_domain_name
    origin_id   = var.origin_domain_name

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_ssl_protocols = var.origin_ssl_protocols
      origin_protocol_policy = "https-only"
    }

    custom_header {
      name = "X-Forwarded-Host"
      value = local.endpoint
    }

    dynamic "custom_header" {
      for_each = var.origin_custom_headers
      content {
        name = custom_header.value["name"]
        value = custom_header.value["value"]
      }
    }
  }

  aliases = [local.endpoint]
  enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id = var.origin_domain_name

    cache_policy_id = aws_cloudfront_cache_policy.this.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.this.id
  }

  viewer_certificate {
    acm_certificate_arn      = var.create_certificate ? aws_acm_certificate.this[0].arn : var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
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
