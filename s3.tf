locals {
  s3_name = "data${lower(random_string.suffix.result)}"
}



module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.s3_name
  acl    = "private"
  force_destroy = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}