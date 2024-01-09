locals {
  mongodb_uri = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${kubernetes_service.mongodb.status.0.load_balancer.0.ingress.0.hostname}:27017/"
}


module "iam_eks_s3_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "s3-fullaccess"

  role_policy_arns = {
    s3    = "arn:aws:iam::aws:policy/AmazonS3FullAccess" #"module.iam_policy.arn"
    batch = "arn:aws:iam::aws:policy/AWSBatchFullAccess"
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:s3-fullaccess"]
    }
  }
}

resource "kubernetes_service_account" "s3" {
  metadata {
    name = "s3-fullaccess"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_eks_s3_role.iam_role_arn
    }
  }
}



resource "kubernetes_deployment" "backend" {

  metadata {
    name = "backend"
    labels = {
      App = "backend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "backend"
      }
    }
    template {
      metadata {
        labels = {
          App = "backend"
        }
      }
      spec {
        service_account_name = "s3-fullaccess"
        container {
          image = "957550945010.dkr.ecr.us-west-2.amazonaws.com/backend:latest"
          name  = "backend-container"

          port {
            container_port = 8080
          }

          env {
            name  = "spring.data.mongodb.uri"
            value = local.mongodb_uri
          }
          env {
            name  = "spring.datasource.url"
            value = "jdbc:postgresql://${kubernetes_service.postgres.spec[0].cluster_ip}:5432/admin"
          }

          env {
            name  = "aws.batch.job-queue"
            value = module.batch.job_queues.high_priority.arn
          }
          env {
            name  = "aws.batch.bucket"
            value = module.s3_bucket.s3_bucket_id
          }
          env {
            name  = "aws.batch.region"
            value = "us-west-2"
          }
          env {
            name  = "aws.batch.batchRegion"
            value = "us-west-2"
          }
          env {
            name  = "aws.batch.job-definitions.2vCpus-16GB"
            value = module.batch.job_definitions.example.arn
          }
          env {
            name  = "aws.batch.job-definitions.16vCpus-120GB"
            value = module.batch.job_definitions.example.arn
          }
          env {
            name  = "aws.batch.job-definitions.experiment"
            value = module.batch.job_definitions.example.arn
          }
          env {
            name  = "logging.level.software.amazon"
            value = "error"
          }
          env {
            name  = "aws.batch.awsLogGroupName"
            value = aws_cloudwatch_log_group.this.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend"
  }
  spec {
    selector = {
      App = "backend"
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
