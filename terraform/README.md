## Decal VM Terraform configuration

[Terraform](https://terraform.io) is used for
infrastructure-as-code things.

Each `.tf` file represents some resource definitions, and
Terraform combines them and makes incremental updates as
necessary.

In addition to the files located here, there are files
containing student and credential data, aptly named
"credentials.auto.tfvars" and "students(-advanced)?.auto.tfvars"

The .tfstate file is also available via more secure channels.

## Setup (untested)

1. Acquire a version of terraform, I downloaded "terraform_0.11.1_linux_amd64.zip"
   and unpacked it.
2. Place the `terraform.tfstate`, `*.auto.tfvars`, and `*.tf` files from this directory into the same one as the `terraform` binary.
3. Run `./terraform init`
4. Run `./terraform plan` to see what it thinks it should do, and `./terraform apply` to tell to it to that.
5. Changes to a single resource can be made by doing something like `./terraform apply -target="dnsimple_record.staff-puppet"`
