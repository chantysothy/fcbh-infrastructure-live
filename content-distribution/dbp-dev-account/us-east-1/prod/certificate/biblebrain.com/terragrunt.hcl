# member-account: dbp-dev

# Note: since biblebrain.com domain is used by a Cloudfront distribution, a certificate must be created in us-east-1 in the account containing 
# the cloudfront distribution. Certificates cannot be referenced from other regions or accounts due to the KMS key used to encrypt the cert 
# (https://aws.amazon.com/premiumsupport/knowledge-center/acm-export-certificate/)


terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//certificate?ref=v0.1.6"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  namespace                   = "dbp"
  stage                       = ""
  name                        = "cert"
  domain_name                 = "biblebrain.com"
  subject_alternative_names   = ["*.biblebrain.com", "uploader.biblebrain.com", "*.uploader.biblebrain.com", "downloader.biblebrain.com", "*.downloader.biblebrain.com"]
  process_domain_validation_options = false
}
