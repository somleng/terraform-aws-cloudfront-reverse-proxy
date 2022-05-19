# AWS CloudFront Reverse Proxy Terraform module

Terraform module which creates AWS CloudFront resources as a reverse proxy by Terraform AWS provider.

## Usage

```hcl
module "reverse_proxy" {
  source = "github.com/somleng/terraform-aws-cloudfront-reverse-proxy"

  host = "dashboard.example.com"
  origin = "dashboard.somleng.org"
  zone_id = aws_route53_zone.example_com.zone_id # Optional. Leave blank if not using route53.
  certificate_arn = "existing-certificate-arn" # Optional. Leave blank to create a new certificate.
}
```

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
