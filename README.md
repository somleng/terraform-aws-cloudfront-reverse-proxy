# AWS CloudFront Reverse Proxy Terraform module

Terraform module which creates AWS CloudFront resources as a reverse proxy by Terraform AWS provider.

## Usage

```hcl
module "proxy" {
  source = "github.com/somleng/terraform-aws-cloudfront-reverse-proxy"

  origin_domain_name = "twilreapi.somleng.org"
  domain_name = "example.com"
  host_name = "api"
  zone_id = aws_route53_zone.example_com.zone_id
}
```

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
