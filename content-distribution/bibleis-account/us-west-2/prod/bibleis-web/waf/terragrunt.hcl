# member-account: bibleis

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//waf?ref=v0.1.7"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {

  namespace = "bibleis"
  stage     = ""
  name      = "web"
  limit = 500
  alb_arn = ""
}
