variable "do_token" {}
variable "dnsimple_token" {}
variable "dnsimple_account" {}

variable "decal_ssh_fingerprint" {
  type = "list"
}

variable "students" {
  type = "list"
}

variable "advanced_students" {
  type = "list"
}

variable "berkeley_subnets" {
  type = "list"
}

variable "berkeley_subnets6" {
  type = "list"
}

variable "internal_subnet" {
  type    = "list"
  default = ["10.46.0.0/16"]
}

provider "digitalocean" {
  token = "${ var.do_token }"
}

provider "dnsimple" {
  token   = "${ var.dnsimple_token }"
  account = "${ var.dnsimple_account }"
}
