variable "berkeley_subnets" { type = "list" }
variable "berkeley_subnets6" { type = "list" }

variable "do_token" {}
variable "decal_ssh_fingerprint" { type = "list" }

variable "students" { type = "list" }

provider "digitalocean" {
    token = "${var.do_token}"
}

resource "digitalocean_tag" "staff" {
    name = "staff"
}

resource "digitalocean_tag" "student" {
    name = "student"
}

resource "digitalocean_firewall" "student_firewall" {
    name = "only-uc-berkeley"
    tags = [ "${ digitalocean_tag.staff.id }", "${ digitalocean_tag.student.id }" ]

    inbound_rule = [
        {
            protocol         = "tcp"
            port_range     = "1-65535"
            source_addresses = "${ concat(var.berkeley_subnets, var.berkeley_subnets6) }"
        },
        {
            protocol           = "udp"
            port_range       = "1-65535"
            source_addresses   = "${ concat(var.berkeley_subnets, var.berkeley_subnets6) }"
        },
        {
            protocol         = "icmp"
            source_addresses = "${ concat(var.berkeley_subnets, var.berkeley_subnets6) }"
        }
    ]
}

resource "digitalocean_droplet" "staff" {
  image              = "debian-9-x64"
  name               = "staff.decal.xcf.sh"
  region             = "sfo2"
  size               = "1gb"
  private_networking = "true"
  ssh_keys           = [ "${var.decal_ssh_fingerprint}" ]
  tags               = [ "${ digitalocean_tag.staff.id }" ]
}

resource "digitalocean_droplet" "students" {

  count = "${ length(var.students) }"

  image              = "debian-9-x64"
  name               = "${ element(var.students, count.index) }.decal.xcf.sh"
  region             = "sfo2"
  size               = "1gb"
  private_networking = "true"
  ssh_keys           = [ "${ var.decal_ssh_fingerprint }" ]
  tags               = [ "${ digitalocean_tag.student.id }" ]

}

output "staff_ip" {
  value = "${ digitalocean_droplet.staff.ipv4_address }"
}

output "student_ips" {
  value = "${ digitalocean_droplet.students.*.ipv4_address }"
}
