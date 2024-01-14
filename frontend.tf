resource "kubernetes_deployment" "frontend" {
  depends_on = [ kubernetes_service.frontend ]
  metadata {
    name = "frontend"
    labels = {
      App = "frontend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          App = "frontend"
        }
      }
      spec {
        container {
          image = "957550945010.dkr.ecr.us-west-2.amazonaws.com/frontend:latest"
          name  = "frontend-container"

          port {
            container_port = 80
          }
          env {
            name  = "REACT_APP_API_DOMAIN"
            value =  "http://${kubernetes_service.backend.status.0.load_balancer.0.ingress.0.hostname}/ja"
          }

          #   resources {
          #     limits = {
          #       cpu    = "0.5"
          #       memory = "512Mi"
          #     }
          #     requests = {
          #       cpu    = "250m"
          #       memory = "50Mi"
          #     }
          #   }
        }
      }
    }
  }
}



resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
  }
  spec {
    selector = {
      App = "frontend"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}