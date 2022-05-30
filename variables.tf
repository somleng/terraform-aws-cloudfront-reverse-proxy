variable "certificate_arn" {
  description = "The certificate of your domain (eg. *.example.com)"
  type        = string
  default     = null
}

variable "origin" {
  type        = string
  description = "The DNS domain name of your custom origin (e.g. dashboard.somleng.org)"
}

variable "host" {
  type        = string
  description = "The DNS domain name of your host. (e.g. dashboard.example.com)"
}

variable "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
  default = null
}

variable "origin_ssl_protocols" {
  type = list(string)
  default = ["TLSv1.2"]
}

variable "origin_custom_headers" {
  type = list(map(string))
  default = []
}
