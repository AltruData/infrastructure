# resource "kubernetes_deployment" "jupyter" {
#   metadata {
#     name = "jupyter"
#     labels = {
#       App = "jupyter"
#     }
#   }

#   spec {
#     replicas = 1
#     selector {
#       match_labels = {
#         App = "jupyter"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           App = "jupyter"
#         }
#       }
#       spec {
#         container {
#           image = "jupyter/scipy-notebook"
#           name  = "jupyter-container"

#           port {
#             container_port = 8888
#           }

#           # Setting the environment variables and args
#         #   env {
#         #     name = "NOTEBOOK_ARGS"
#         #     value = "--ip=0.0.0.0 --NotebookApp.base_url=/jupyter/ --NotebookApp.allow_origin='*'"
#         #   }
#         # env {
#         #     name = "NOTEBOOK_ARGS"
#         #     value = "--ip=0.0.0.0 --NotebookApp.base_url=/jupyter/ --NotebookApp.allow_origin='*'"
#         #   }
#         }
#       }
#     }
#   }
# }


# resource "kubernetes_service" "jupyter" {
#   metadata {
#     name = "jupyter"
#   }

#   spec {
#     selector = {
#       App = "jupyter"
#     }
#     port {
#       port        = 80
#       target_port = 8888
#     }

#     type = "LoadBalancer"
#   }
# }
