resource "kubernetes_deployment" "mongodb" {
  metadata {
    name = "mongodb"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        App = "mongodb"
      }
    }

    template {
      metadata {
        labels = {
          App = "mongodb"
        }
      }

      spec {
        container {
          image = "mongo:latest"
          name  = "mongodb"

          port {
            container_port = 27017
          }

          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = var.mongodb_username
          }

          env {
            name  = "MONGO_INITDB_ROOT_PASSWORD"
            value = var.mongodb_password
          }

          volume_mount {
            mount_path = "/data/db"
            name       = "mongodb-data"
          }
        }

        volume {
          name = "mongodb-data"

          persistent_volume_claim {
            claim_name = "mongodb-claim0"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mongodb_data" {
  metadata {
    name = "mongodb-claim0"
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
resource "kubernetes_service" "mongodb" {
  metadata {
    name = "mongodb"
  }

  spec {
    selector = {
      App = "mongodb"
    }

    port {
      port        = 27017
      target_port = 27017
    }

    type = "LoadBalancer"
  }
}
