
output "ingress_floating_ip" {
  value = digitalocean_floating_ip.cluster_ingress.ip_address
}

output "server_droplet_ips" {
  value = join(",", digitalocean_droplet.nomad_server[*].ipv4_address)
}

output "ingress_droplet_ip" {
  value = digitalocean_droplet.ingress_client.ipv4_address
}

// output "consul_access_cmd" {
//   value = format(<<EOT
//   ssh -f -N -o IdentitiesOnly=yes -i ./id_rsa -L 8500:%s:8500 root@%s
//   export CONSUL_HTTP_ADDR=127.0.0.1:8500
//   # Or check localhost:8500 in the browser
//   consul members list
//   EOT
//   , digitalocean_droplet.nomad_server[0].ipv4_address, digitalocean_droplet.ingress_client.ipv4_address)
// }
// output "vault_access_cmd" {
//   value = format(<<EOT
//   ssh -f -N -o IdentitiesOnly=yes -i ./id_rsa -L 8200:%s:8200 root@%s
//   export VAULT_ADDR=http://127.0.0.1:8200
//   # Or check localhost:8200 in the browser
//   vault status
//   EOT
//   , digitalocean_droplet.nomad_server[0].ipv4_address, digitalocean_droplet.ingress_client.ipv4_address)
// }
// output "nomad_access_cmd" {
//   value = format(<<EOT
//   ssh -f -N -o IdentitiesOnly=yes -i ./id_rsa -L 4646:%s:4646 root@%s
//   export NOMAD_ADDR=http://127.0.0.1:4646
//   # Or check localhost:4646 in the browser
//   nomad status
//   EOT
//   , digitalocean_droplet.nomad_server[0].ipv4_address, digitalocean_droplet.ingress_client.ipv4_address)
// }
// output "traefik_access_cmd" {
//   value = format(<<EOT
//   ssh -f -N -o IdentitiesOnly=yes -i ./id_rsa -L 8081:%s:8081 root@%s
//   # Check localhost:8081 in the browser
//   EOT
//   , digitalocean_droplet.ingress_client.ipv4_address, digitalocean_droplet.ingress_client.ipv4_address)
// }