terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}


# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_images" "cluster_server" {
  filter {
    key    = "private"
    values = ["true"]
  }
  filter {
    key    = "name"
    values = ["nomad_cluster"]
  }
  sort {
    key       = "created"
    direction = "desc"
  }
}

data "template_file" "user_data_server" {
  template = file("${path.root}/user-data-server.sh")

  vars = {
    nomad_servers_count = var.nomad_servers_count
    retry_join = chomp(
      join(
        " ",
        formatlist("%s=%s", keys(local.retry_join), values(local.retry_join)),
      ),
    )
  }
}

data "template_file" "user_data_client" {
  template = file("${path.root}/user-data-client.sh")

  vars = {
    retry_join = chomp(
      join(
        " ",
        formatlist("%s=%s ", keys(local.retry_join), values(local.retry_join)),
      ),
    )
  }
}

resource "digitalocean_ssh_key" "default" {
  name       = "Nomad Cluster"
  public_key = file("${path.root}/id_rsa.pub")
}

resource "digitalocean_droplet" "nomad_server" {
  count = var.nomad_servers_count
  image = data.digitalocean_images.cluster_server.images[0].id
  # Consul members name must be unique
  name   = "nomad-cluster-server-${count.index}"
  region = var.do_region
  size   = var.server_droplet_size
  user_data = data.template_file.user_data_server.rendered
  ssh_keys  = [digitalocean_ssh_key.default.fingerprint]
  vpc_uuid  = digitalocean_vpc.cluster.id

  tags = [
    local.retry_join.tag_name
  ]
}

resource "digitalocean_droplet" "nomad_client" {
  count = var.nomad_clients_count
  image = data.digitalocean_images.cluster_server.images[0].id
  # Consul members name must be unique
  name   = "nomad-cluster-general-client-${count.index}"
  region = var.do_region
  size   = var.client_droplet_size
  user_data = data.template_file.user_data_client.rendered
  ssh_keys  = [digitalocean_ssh_key.default.fingerprint]
  vpc_uuid  = digitalocean_vpc.cluster.id

  tags = [
    local.retry_join.tag_name
  ]
}

resource "digitalocean_droplet" "ingress_client" {
  image = data.digitalocean_images.cluster_server.images[0].id
  # Consul members name must be unique
  name     = "nomad-cluster-ingress"
  region   = var.do_region
  vpc_uuid = digitalocean_vpc.cluster.id
  size   = var.ingress_droplet_size
  user_data = data.template_file.user_data_client.rendered
  ssh_keys  = [digitalocean_ssh_key.default.fingerprint]

  tags = [
    local.retry_join.tag_name
  ]
}

resource "digitalocean_floating_ip" "cluster_ingress" {
  region = var.do_region
}

resource "digitalocean_floating_ip_assignment" "cluster_ingress" {
  ip_address = digitalocean_floating_ip.cluster_ingress.ip_address
  droplet_id = digitalocean_droplet.ingress_client.id
}

locals {
  cluster_droplet_ids = concat(
    [digitalocean_droplet.ingress_client.id],
    digitalocean_droplet.nomad_client.*.id,
    digitalocean_droplet.nomad_server.*.id
  )
}

# Firewall
resource "digitalocean_firewall" "cluster_traffic" {
  name = "nomad-cluster-intra-traffic"

  droplet_ids = concat(
    digitalocean_droplet.nomad_client.*.id,
    digitalocean_droplet.nomad_server.*.id
  )


  inbound_rule {
    protocol           = "tcp"
    port_range         = "1-65535"
    source_droplet_ids = local.cluster_droplet_ids
  }
  inbound_rule {
    protocol           = "udp"
    port_range         = "1-65535"
    source_droplet_ids = local.cluster_droplet_ids
  }
  inbound_rule {
    protocol           = "icmp"
    port_range         = "1-65535"
    source_droplet_ids = local.cluster_droplet_ids
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_firewall" "ingress" {
  name = "nomad-cluster-ingress"

  droplet_ids = [digitalocean_droplet.ingress_client.id]


  # All tcp traffic on port 22, 80 and 443 from outside
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # All traffic from cluster
  inbound_rule {
    protocol           = "tcp"
    port_range         = "1-65535"
    source_droplet_ids = local.cluster_droplet_ids
  }
  inbound_rule {
    protocol           = "udp"
    port_range         = "1-65535"
    source_droplet_ids = local.cluster_droplet_ids
  }
  inbound_rule {
    protocol           = "icmp"
    port_range         = "1-65535"
    source_droplet_ids = local.cluster_droplet_ids
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
