variable "do_token" {
  type = string
}

variable "do_region" {
  type = string
  default = "lon1"
}

variable "droplet_name" {
  type = string
  default = "nomad-cluster-packer"
}

variable "snapshot_name" {
  type = string
  default = "nomad_cluster"
}