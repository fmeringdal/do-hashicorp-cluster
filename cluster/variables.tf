variable "do_token" {
  type = string
}

variable "snapshot" {
  type = string
}

variable "do_region" {
  type    = string
  default = "lon1"
}

variable "nomad_servers_count" {
  default = 1
}

variable "nomad_clients_count" {
  default = 1
}

variable "server_droplet_size" {
  type = string
  default = "s-1vcpu-1gb"
}
variable "client_droplet_size" {
  type = string
  default = "s-1vcpu-1gb"
}
variable "ingress_droplet_size" {
  type = string
  default = "s-1vcpu-1gb"
}

# https://www.consul.io/docs/install/cloud-auto-join#digital-ocean
// variable "retry_join" {
//   description = "Used by Consul to automatically form a cluster."
//   type        = map(string)

//   default = {
//     provider  = "digitalocean"
//     region    = var.do_region
//     tag_name  = "nomad-cluster"
//     api_token = var.do_token
//   }
// }

locals {
  retry_join = {
    provider  = "digitalocean"
    region    = var.do_region
    tag_name  = "nomad-cluster"
    api_token = var.do_token
  }
}