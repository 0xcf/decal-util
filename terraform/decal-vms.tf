resource "digitalocean_tag" "staff" {
  name = "staff"
}

resource "digitalocean_tag" "student" {
  name = "student"
}

resource "digitalocean_tag" "basic" {
  name = "basic"
}

resource "digitalocean_tag" "advanced" {
  name = "advanced"
}

resource "digitalocean_droplet" "staff" {
  image              = "debian-9-x64"
  name               = "staff.decal.xcf.sh"
  region             = "sfo2"
  size               = "${ var.default_vm_size }"
  private_networking = "true"
  ssh_keys           = ["${ var.decal_ssh_fingerprint }"]
  tags               = ["${ digitalocean_tag.staff.id }"]
}

resource "digitalocean_droplet" "test" {
  image              = "debian-9-x64"
  name               = "test.decal.xcf.sh"
  region             = "sfo2"
  size               = "${ var.default_vm_size }"
  private_networking = "true"
  ssh_keys           = ["${ var.decal_ssh_fingerprint }"]
  tags               = ["${ digitalocean_tag.staff.id }"]
}

resource "digitalocean_droplet" "students" {
  count = "${ length(var.students) }"

  image              = "debian-9-x64"
  name               = "${ element(var.students, count.index) }.decal.xcf.sh"
  region             = "sfo2"
  size               = "${ var.default_vm_size }"
  private_networking = "true"
  ssh_keys           = ["${ var.decal_ssh_fingerprint }"]
  tags               = ["${ digitalocean_tag.student.id }", "${ digitalocean_tag.basic.id }"]
}

resource "digitalocean_droplet" "advanced_students" {
  count = "${ length(var.advanced_students) }"

  image              = "debian-9-x64"
  name               = "${ element(var.advanced_students, count.index) }.decal.xcf.sh"
  region             = "sfo2"
  size               = "${ var.default_vm_size }"
  private_networking = "true"
  ssh_keys           = ["${ var.decal_ssh_fingerprint }"]
  tags               = ["${ digitalocean_tag.student.id }", "${ digitalocean_tag.advanced.id }"]
}

output "student_public_ips" {
  value = "${ digitalocean_droplet.students.*.ipv4_address }"
}

output "advanced_student_public_ips" {
  value = "${ digitalocean_droplet.advanced_students.*.ipv4_address }"
}

output "student_private_ips" {
  value = "${ digitalocean_droplet.students.*.ipv4_address_private }"
}

output "advanced_student_private_ips" {
  value = "${ digitalocean_droplet.advanced_students.*.ipv4_address_private }"
}

output "staff_public_ip" {
  value = "${ digitalocean_droplet.staff.ipv4_address }"
}
