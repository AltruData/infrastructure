# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "mongodb_username" {
  description = "The username for MongoDB"
  type        = string
  default     = "admin"  # You can set a default or remove the default to make it required
}

variable "mongodb_password" {
  description = "The password for MongoDB"
  type        = string
  default     = "admin"
}