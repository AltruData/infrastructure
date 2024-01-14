# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "lb_ip" {
  value = kubernetes_service.frontend.status.0.load_balancer.0.ingress.0.hostname
}
output "backend_ip" {
  value = kubernetes_service.backend.status.0.load_balancer.0.ingress.0.hostname
}

output "postgre_uri" {
  value =  kubernetes_service.postgres.status.0.load_balancer.0.ingress.0.hostname
  description = "POSTGRE URI"
}

output "postgres_cluster_ip" {
  description = "The internal cluster IP of the PostgreSQL service"
  value       = kubernetes_service.postgres.spec[0].cluster_ip
}

output "mongodb_uri" {
  description = "mongodb_uri"
  value       = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${kubernetes_service.mongodb.status.0.load_balancer.0.ingress.0.hostname}:27017"
}

output "jupyter_uri" {
  description = "jupter_uri"
  value = kubernetes_service.jupyter.status.0.load_balancer.0.ingress.0.hostname
}

output "private_mongodb_uri" {
  description = "private mongodb uri"
  value       = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${kubernetes_service.mongodb.spec.0.cluster_ip}:27017/"
}


output "image_pull_batch" {
  description = "arn"
  value       = aws_iam_role.ecs_task_execution_role.arn
}
      

output "image_pull_eks" {
  description = "arn"
  value       = aws_iam_role.ecr-pull.arn
}
