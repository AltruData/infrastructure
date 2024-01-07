module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

  rules = {
    logs = {
      description   = "Capture log data"
      event_pattern = jsonencode({ "source" : ["aws.batch"] })
    }
  }

  targets = {
    logs = [
      {
        name = "lambda-batch-job"
        arn  = module.notifer.lambda_function_arn
      }
    ]
  }
}
