terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.8.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "nomad" {
  address = module.cluster.nomad_address
}

# Pre-flight check.
resource "null_resource" "preflight_check" {
  provisioner "local-exec" {
    command = <<EOF
curl --version && \
packer --version && \
nomad --version
EOF
  }
}

module "image" {
  depends_on = [null_resource.preflight_check]
}


module "cluster" {
  depends_on = [null_resource.preflight_check]
  source     = "./cluster"
  do_token    = var.do_token
  snapshot_id = module.image.snapshot_id
  ssh_key     = var.ssh_key
  region      = var.region
  ip_range    = var.ip_range
}


module "jobs" {
  depends_on = [null_resource.preflight_check]
}

module "vault" {
  depends_on = [null_resource.preflight_check]
}


