resource "digitalocean_vpc" "cluster" {
  name     = "nomad-cluster"
  region   = var.do_region
  // ip_range = "10.10.10.0/24"
  ip_range = "10.0.0.0/24"
}