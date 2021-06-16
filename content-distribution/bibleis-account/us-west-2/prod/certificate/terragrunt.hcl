# member-account: bibleis

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//certificate?ref=v0.1.6"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  namespace                   = "bibleis"
  stage                       = "prod"
  name                        = "certificate"
  domain_name                 = "bible.is"
  subject_alternative_names   = ["live.bible.is", "newdata.bible.is"]
}
