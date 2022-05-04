variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "The certificate of your domain (eg. *.example.com)"
  type        = string
  default     = null
}

variable "origin_domain_name" {
  type        = string
  description = "The DNS domain name of your custom origin (e.g. twilreapi.somleng.org)"
}

variable "domain_name" {
  type        = string
  description = "The DNS domain name of your domain name (e.g. example.com)"
}

variable "host_name" {
  type        = string
  description = "The host name of your domain name."
}

variable "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
}

variable "origin_ssl_protocols" {
  type = list(string)
  default = ["TLSv1.2"]
}

variable "origin_custom_headers" {
  type = list(map(string))
  default = []
}
