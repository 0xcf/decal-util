variable "do_token" {}
variable "dnsimple_token" {}
variable "dnsimple_account" {}

variable "decal_ssh_fingerprint" {
  type = "list"
}

variable "students" {
  type = "list"
}

variable "berkeley_subnets" {
  type = "list"
}

variable "berkeley_subnets6" {
  type = "list"
}

provider "digitalocean" {
  token = "${ var.do_token }"
}

provider "dnsimple" {
  token   = "${ var.dnsimple_token }"
  account = "${ var.dnsimple_account }"
}

resource "digitalocean_tag" "staff" {
  name = "staff"
}

resource "digitalocean_tag" "student" {
  name = "student"
}

resource "digitalocean_firewall" "student_firewall" {
  name = "only-uc-berkeley"
  tags = ["${ digitalocean_tag.staff.id }", "${ digitalocean_tag.student.id }"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "1-65535"
      source_addresses = "${ concat(var.berkeley_subnets, var.berkeley_subnets6) }"
    },
    {
      protocol         = "udp"
      port_range       = "1-65535"
      source_addresses = "${ concat(var.berkeley_subnets, var.berkeley_subnets6) }"
    },
    {
      protocol         = "icmp"
      port_range       = ""
      source_addresses = "${ concat(var.berkeley_subnets, var.berkeley_subnets6) }"
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

}

resource "digitalocean_droplet" "staff" {
  image              = "debian-9-x64"
  name               = "staff.decal.xcf.sh"
  region             = "sfo2"
  size               = "1gb"
  private_networking = "true"
  ssh_keys           = ["${ var.decal_ssh_fingerprint }"]
  tags               = ["${ digitalocean_tag.staff.id }"]
}

resource "digitalocean_droplet" "students" {
  count = "${ length(var.students) }"

  image              = "debian-9-x64"
  name               = "${ element(var.students, count.index) }.decal.xcf.sh"
  region             = "sfo2"
  size               = "1gb"
  private_networking = "true"
  ssh_keys           = ["${ var.decal_ssh_fingerprint }"]
  tags               = ["${ digitalocean_tag.student.id }"]
}

resource "dnsimple_record" "student-vms" {
  count = "${ length(var.students) }"

  domain = "xcf.sh"
  name   = "${ element(var.students, count.index) }.decal"
  type   = "A"
  ttl    = 3600
  value  = "${ element(digitalocean_droplet.students.*.ipv4_address, count.index) }"
}

resource "dnsimple_record" "staff" {
  domain = "xcf.sh"
  name   = "staff.decal"
  type   = "A"
  ttl    = 3600
  value  = "${ digitalocean_droplet.staff.ipv4_address }"
}

resource "dnsimple_record" "staff-puppet" {
  domain = "xcf.sh"
  name   = "puppet.decal"
  type   = "CNAME"
  ttl    = 3600
  value  = "${ digitalocean_droplet.staff.name }"
}

output "staff_public_ip" {
  value = "${ digitalocean_droplet.staff.ipv4_address }"
}

output "student_public_ips" {
  value = "${ digitalocean_droplet.students.*.ipv4_address }"
}
