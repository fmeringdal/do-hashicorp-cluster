job "postgres" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "regexp"
    value     = "nomad-cluster-general-client-[0-9]+$"
  }

  group "postgres" {
    count = 1

        network {
          port  "db"  {
            static = 5432
          }
        }

    task "postgres" {
      driver = "docker"
      config {
        image = "postgres"
        network_mode = "host"
      }
      env {
          POSTGRES_USER="root"
          POSTGRES_PASSWORD="rootpassword"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = 250
        memory = 256
      }
      service {
        name = "postgres"
        tags = []
        port = "db"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

  }

  update {
    max_parallel = 1
    min_healthy_time = "5s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }
}