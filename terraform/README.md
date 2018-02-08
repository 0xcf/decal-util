## Decal VM Terraform configuration

There are two additional files containing sensitive
information to use with this configuration,
credentials.auto.tfvars and students.auto.tfvars.

The .tfstate file is also available via more secure channels.

## Setup (untested)

1. Acquire a version of terraform, I downloaded "terraform_0.11.1_linux_amd64.zip"
   and unpacked it.
2. Place the `terraform.tfstate`, `terraform.tfvars`, `decal-vms.tf`, and appropriate
   `*.auto.tfvars` in the same folder.
3. Run `./terraform init`
4. It should (?) work
