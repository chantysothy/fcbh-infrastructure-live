# member-account: dbp

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//cloudfront?ref=v0.1.6"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# this is unique -- CloudFront certificates must be issued in region us-east-1
# dependency "certificate" {
#   config_path = "../certificate/cloudfront"
#   mock_outputs = {
#       arn = ""
#   }    
# }

inputs = {
  namespace                = "dbp"
  stage                    = "dev"
  name                     = "cloudfront"
  price_class              = "PriceClass_200"
  parent_zone_name         = "dev.dbt.io"
  aliases                  = ["cdn.dev.dbt.io"]
  log_prefix               = "cloudfront/dbp-dev"
  acm_certificate_arn      = "arn:aws:acm:us-east-1:078432969830:certificate/c6f0845a-1ef2-4112-9bc1-8a2d2a0a02f6"
  minimum_protocol_version = "TLSv1.1_2016"
  cors_allowed_origins     = ["*.dev.dbt.io"]
  viewer_protocol_policy   = "allow-all"
  origin_force_destroy     = false
  origin_bucket            = "dbp-dev-cloudfront-origin"
}
