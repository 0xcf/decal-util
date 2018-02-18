resource "digitalocean_firewall" "student_firewall" {
  name = "only-uc-berkeley"
  tags = ["${ digitalocean_tag.staff.id }", "${ digitalocean_tag.student.id }"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "1-65535"
      source_addresses = ["${ var.berkeley_subnets }", "${ var.berkeley_subnets6 }", "${ var.internal_subnet }", "${ digitalocean_droplet.students.*.ipv4_address }", "${ digitalocean_droplet.advanced_students.*.ipv4_address}", "${ digitalocean_droplet.staff.ipv4_address }", "${ digitalocean_droplet.test.ipv4_address }"]
    },
    {
      protocol         = "udp"
      port_range       = "1-65535"
      source_addresses = ["${ var.berkeley_subnets }", "${ var.berkeley_subnets6 }", "${ var.internal_subnet }", "${ digitalocean_droplet.students.*.ipv4_address }", "${ digitalocean_droplet.advanced_students.*.ipv4_address}", "${ digitalocean_droplet.staff.ipv4_address }", "${ digitalocean_droplet.test.ipv4_address }"]
    },
    {
      protocol         = "icmp"
      port_range       = ""
      source_addresses = ["${ var.berkeley_subnets }", "${ var.berkeley_subnets6 }", "${ var.internal_subnet }", "${ digitalocean_droplet.students.*.ipv4_address }", "${ digitalocean_droplet.advanced_students.*.ipv4_address}", "${ digitalocean_droplet.staff.ipv4_address }", "${ digitalocean_droplet.test.ipv4_address }"]
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
