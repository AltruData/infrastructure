

locals {
  name = "batch-ex"
  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-batch"
  }
}

data "aws_region" "current" {}

################################################################################
# Batch Module
################################################################################

module "batch_disabled" {
  source = "terraform-aws-modules/batch/aws"
  create = false
}

module "batch" {
  source = "terraform-aws-modules/batch/aws"

  instance_iam_role_name        = "${local.name}-ecs-instance"
  instance_iam_role_path        = "/batch/"
  instance_iam_role_description = "IAM instance role/profile for AWS Batch ECS instance(s)"
  instance_iam_role_tags = {
    ModuleCreatedRole = "Yes"
  }

  service_iam_role_name        = "${local.name}-batch"
  service_iam_role_path        = "/batch/"
  service_iam_role_description = "IAM service role for AWS Batch"
  service_iam_role_tags = {
    ModuleCreatedRole = "Yes"
  }

  create_spot_fleet_iam_role      = true
  spot_fleet_iam_role_name        = "${local.name}-spot"
  spot_fleet_iam_role_path        = "/batch/"
  spot_fleet_iam_role_description = "IAM spot fleet role for AWS Batch"
  spot_fleet_iam_role_tags = {
    ModuleCreatedRole = "Yes"
  }

  compute_environments = {
    a_fargate = {
      name_prefix = "fargate"

      compute_resources = {
        type      = "FARGATE"
        max_vcpus = 256

        security_group_ids = [module.vpc_endpoint_security_group.security_group_id]
        subnets            = module.vpc.private_subnets

        # `tags = {}` here is not applicable for spot
      }
    }

    b_fargate_spot = {
      name_prefix = "fargate_spot"

      compute_resources = {
        type      = "FARGATE_SPOT"
        max_vcpus = 256

        security_group_ids = [module.vpc_endpoint_security_group.security_group_id]
        subnets            = module.vpc.private_subnets

        # `tags = {}` here is not applicable for spot
      }
    }
  }

  # Job queus and scheduling policies
  job_queues = {
    low_priority = {
      name     = "LowPriorityFargate"
      state    = "ENABLED"
      priority = 1

      tags = {
        JobQueue = "Low priority job queue"
      }
    }

    high_priority = {
      name     = "HighPriorityFargate"
      state    = "ENABLED"
      priority = 99

      fair_share_policy = {
        compute_reservation = 1
        share_decay_seconds = 3600

        share_distribution = [{
          share_identifier = "A1*"
          weight_factor    = 0.1
          }, {
          share_identifier = "A2"
          weight_factor    = 0.2
        }]
      }

      tags = {
        JobQueue = "High priority job queue"
      }
    }
  }

  job_definitions = {
    example = {
      name                  = local.name
      propagate_tags        = true
      platform_capabilities = ["FARGATE"]

      container_properties = jsonencode({
        command = ["ls", "-la"]
        image   = "957550945010.dkr.ecr.us-west-2.amazonaws.com/synthdata:latest"
        fargatePlatformConfiguration = {
          platformVersion = "LATEST"
        },
        jobRoleArn= aws_iam_role.ecs_task_execution_role.arn
        resourceRequirements = [
          { type = "VCPU", value = "16" },
          { type = "MEMORY", value = "122880" }
        ],
        executionRoleArn = aws_iam_role.ecs_task_execution_role.arn
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.this.id
            awslogs-region        = var.region
            awslogs-stream-prefix = local.name
          }
        }
      })
      attempt_duration_seconds = 36000
      retry_strategy = {
        attempts = 3
        evaluate_on_exit = {
          retry_error = {
            action       = "RETRY"
            on_exit_code = 1
          }
          exit_success = {
            action       = "EXIT"
            on_exit_code = 0
          }
        }
      }

      tags = {
        JobDefinition = "Example"
      }
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc_endpoint_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-vpc-endpoint"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  # Allow all inbound traffic
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-all"]

  # Allow all outbound traffic
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.tags
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${local.name}-ecs-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/batch/${local.name}"
  retention_in_days = 1

  tags = local.tags
}

