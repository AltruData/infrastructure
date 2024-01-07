resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name = "postgres-claim0"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          image = "postgres:14.10"
          name  = "postgres"
          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_DB"
            value = "admin"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "admin" # Consider using a more secure method for secrets
          }

          env {
            name  = "POSTGRES_USER"
            value = "admin"
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "postgres-claim0"
          }
        }

        volume {
          name = "postgres-claim0"

          persistent_volume_claim {
            claim_name = "postgres-claim0"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "LoadBalancer"
  }
}
