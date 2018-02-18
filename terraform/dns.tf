resource "dnsimple_record" "student-vms" {
  count = "${ length(var.students) }"

  domain = "xcf.sh"
  name   = "${ element(var.students, count.index) }.decal"
  type   = "A"
  ttl    = 3600
  value  = "${ element(digitalocean_droplet.students.*.ipv4_address, count.index) }"
}

resource "dnsimple_record" "advanced-vms" {
  count = "${ length(var.advanced_students) }"

  domain = "xcf.sh"
  name   = "${ element(var.advanced_students, count.index) }.decal"
  type   = "A"
  ttl    = 3600
  value  = "${ element(digitalocean_droplet.advanced_students.*.ipv4_address, count.index) }"
}

resource "dnsimple_record" "staff" {
  domain = "xcf.sh"
  name   = "staff.decal"
  type   = "A"
  ttl    = 3600
  value  = "${ digitalocean_droplet.staff.ipv4_address }"
}

resource "dnsimple_record" "test" {
  domain = "xcf.sh"
  name   = "test.decal"
  type   = "A"
  ttl    = 3600
  value  = "${ digitalocean_droplet.test.ipv4_address }"
}

resource "dnsimple_record" "staff-puppet" {
  domain = "xcf.sh"
  name   = "puppet.decal"
  type   = "A"
  ttl    = 3600
  value  = "${ digitalocean_droplet.staff.ipv4_address }"
}
