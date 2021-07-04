output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "fqdn" {
  description = "FQDN built using the zone domain and name."
  value       = aws_route53_record.this.fqdn
}

