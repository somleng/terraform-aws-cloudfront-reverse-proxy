# AWS CloudFront Reverse Proxy Terraform module

Terraform module which creates AWS CloudFront resources as a reverse proxy by Terraform AWS provider.

## Usage

```hcl
module "reverse_proxy" {
  source = "github.com/somleng/terraform-aws-cloudfront-reverse-proxy"

  origin_domain_name = "dashboard.somleng.org"
  domain_name = "example.com"
  host_name = "api"
  zone_id = aws_route53_zone.example_com.zone_id # Optional. Leave blank if not using route53.
  certificate_arn = "existing-certificate-arn" # Optional. Leave it blank to create a new certificate.
}
```

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
