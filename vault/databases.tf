resource "vault_database_secret_backend_connection" "postgres" {
  backend           = vault_mount.db.path
  name              = "postgres"
  allowed_roles     = ["*"]
  verify_connection = true

  postgresql {
    connection_url = "postgresql://{{username}}:{{password}}@postgres.service.consul:5432/postgres?sslmode=disable"
  }

  data = {
    username = "root"
    password = "rootpassword"
  }
}

resource "null_resource" "rotate_pg_root_key" {
  provisioner "local-exec" {
    command = "vault write -force ${vault_mount.db.path}/rotate-root/${vault_database_secret_backend_connection.postgres.name}"
  }
  depends_on = [
    vault_database_secret_backend_connection.postgres,
  ]
}

resource "vault_database_secret_backend_role" "role" {
  backend     = vault_mount.db.path
  name        = "my-role"
  db_name     = vault_database_secret_backend_connection.postgres.name
  default_ttl = 1800
  max_ttl     = 7200
  //   CREATE USER "{{name}}" WITH ENCRYPTED PASSWORD '{{password}}' VALID UNTIL
  // '{{expiration}}';
  // GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO "{{name}}";
  // GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "{{name}}";
  // GRANT ALL ON SCHEMA public TO "{{name}}";
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
  ]
}