job "traefik" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "nomad-cluster-ingress"
  }

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "api" {
        static = 8081
      }
    }

    service {
      name = "traefik"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v2.2"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data = <<EOF
[entryPoints]
	[entryPoints.http]
	address = ":80"

    [entryPoints.websecure]
    address = ":443"

    [entryPoints.traefik]
    address = ":8081"

# [certificatesResolvers.myresolver.acme]
#   email = "<youremail@company.com>"
#   storage = "acme.json"
#   [certificatesResolvers.myresolver.acme.httpChallenge]
#     # used during the challenge
#     entryPoint = "http"

[api]
    dashboard = true
    insecure  = true

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      address = "127.0.0.1:8500"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
