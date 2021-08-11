data_dir = "/opt/nomad/data"
bind_addr = "IP_ADDRESS"
datacenter = "dc1"


# Enable the server
server {
  enabled = true
  bootstrap_expect = SERVER_COUNT
}

consul {
  address = "127.0.0.1:8500"
}

vault {
  enabled = true
  address = "http://active.vault.service.consul:8200"
  token = "NOMAD_VAULT_TOKEN"
  create_from_role = "nomad-cluster"
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}