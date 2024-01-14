locals {
  s3_name = "data${lower(random_string.suffix.result)}"
}



module "s3_bucket" {
  source     = "terraform-aws-modules/s3-bucket/aws"

  bucket                   = local.s3_name
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  depends_on = [kubernetes_service.frontend]

  bucket = module.s3_bucket.s3_bucket_id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["http://${kubernetes_service.frontend.status.0.load_balancer.0.ingress.0.hostname}"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
