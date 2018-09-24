variable "do_token" {}
variable "dnsimple_token" {}
variable "dnsimple_account" {}

variable "decal_ssh_fingerprint" {
  type = "list"

  default = ["e5:95:8d:ac:35:81:f3:ec:9a:57:2a:23:b8:2f:19:7c"]
}

variable "default_vm_size" {
  type = "string"
  default = "s-1vcpu-1gb"
}

variable "students" {
  type = "list"
}

variable "advanced_students" {
  type = "list"
}

variable "berkeley_subnets" {
  type = "list"

  default = ["128.32.0.0/16", "136.152.0.0/16", "169.229.0.0/16"]
}

variable "berkeley_subnets6" {
  type = "list"

  default = ["2607:f140::/32"]
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
