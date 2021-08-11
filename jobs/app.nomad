job "app" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "regexp"
    value     = "nomad-cluster-general-client-[0-9]+$"
  }

  group "app" {
    count = 1

    network {
      port  "http"{
        to = 80
      }
    }

    service {
      name = "app"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.app.entryPoints=http",
        "traefik.http.routers.app.rule=Path(`/`)"
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "2s"
      }
    }

    task "app" {
      vault {
        policies = ["default_nomad_job"]

        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      template {
        data = <<EOF
          {{ with secret "database/creds/my-role" }}
              DB_USERNAME = {{ .Data.username }}
              DB_PASSWORD = {{ .Data.password | toJSON }}
	      DB_URL = postgresql://{{ .Data.username }}:{{ .Data.password | toJSON }}@postgres.service.consul:5432/postgres
          {{ end }}
        EOF
        env = true
        destination = "${NOMAD_SECRETS_DIR}/foo.txt"
      }
      env {
        PORT    = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      driver = "docker"

      config {
        image = "fmeringdal/do-hashicorp-platform-demo"
        ports = ["http"]
      }
    }
  }
}
