resource "vault_auth_backend" "userpass" {
  type = "userpass"

  tune {
    default_lease_ttl = "90000s"
    max_lease_ttl     = "90000s"
  }
}

resource "vault_generic_endpoint" "u1" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/u1"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["${vault_policy.admin.name}"],
  "password": "${var.vault_admin_password}",
  "username": "admin"
}
EOT
}