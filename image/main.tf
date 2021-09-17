terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.8.0"
    }
  }
}


locals {
  build_image = var.image == ""
  image       = local.build_image ? data.digitalocean_image.built[0] : data.digitalocean_image.existing[0]
}

resource "random_pet" "name" {
  count = local.build_image ? 1 : 0
}

resource "null_resource" "packer_build" {
  count = local.build_image ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
cd ${path.module}/packer && \
  packer build -force \
    -var 'name=hashi-${random_pet.name[0].id}' \
    -var 'region=${var.region}' \
    -var 'token=${var.do_token}' \
    do-packer.pkr.hcl
EOF
  }
}

data "digitalocean_image" "built" {
  depends_on = [null_resource.packer_build]
  count      = local.build_image ? 1 : 0
  name       = "hashi-${random_pet.name[0].id}"
}

data "digitalocean_image" "existing" {
  count = local.build_image ? 0 : 1
  name  = var.image
}

output "snapshot_id" {
  value = local.image.id
}