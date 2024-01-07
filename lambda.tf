
module "notifer" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "trusetic-notifer"

  #   s3_bucket = "my_lambda_functions"
  #   s3_key    = "lambda_function_payload.zip"

  handler             = "index.handler" # Adjust based on your runtime and handler
  attach_policy_jsons = true
  policy_jsons = [<<EOF
  {
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
    ],
  }
  EOF
  ]
  runtime                = "nodejs18.x" # Adjust to the runtime you are using
  create_package         = false
  local_existing_package = "../../notifier/myFunction.zip"

  # vpc_subnet_ids                     =  module.vpc.private_subnets
  # vpc_security_group_ids             = [module.vpc.default_security_group_id]
  # attach_network_policy              = true
  # replace_security_groups_on_destroy = true
  # replacement_security_group_ids     = [module.vpc.default_security_group_id]
  environment_variables = {
    REGION          = "us-west-2"
    MONGODB_URI     = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${kubernetes_service.mongodb.status.0.load_balancer.0.ingress.0.hostname}:27017"
    DATABASE_NAME   = "synthdata"
    COLLECTION_NAME = "applyInfo"
    # EMAIL           = "marketing@trusetic.com"
  }
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    ScanAmiRule = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["logs"]
    }
  }
}
