# member-account: dbp

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//alb-redirect?ref=v0.x"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                        = "temporary-dummy-id"
    public_subnet_ids             = []
    private_subnet_ids            = []
    vpc_default_security_group_id = ""
  }
}
dependency "certificate_dbt_io" {
  config_path = "../certificate/dbt.io"
  mock_outputs = {
    arn = ""
  }
}

inputs = {
  namespace                   = "dbp"
  stage                       = ""
  name                        = "redirect"
  alb_name        = "redirect-to-4_dbt_io_api"
  redirect_to_host     = "4.dbt.io"
  redirect_to_path = "/api/#{path}"
  redirect_to_port  = 443
  security_groups = [dependency.vpc.outputs.vpc_default_security_group_id]
  subnets         = dependency.vpc.outputs.public_subnet_ids
  host_header_values = ["api.v4.dbtio"]
  certificate_arn = dependency.certificate_dbt_io.arn
}
