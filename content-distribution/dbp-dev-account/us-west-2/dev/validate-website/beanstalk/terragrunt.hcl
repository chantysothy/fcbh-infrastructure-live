# member-account: dbp-dev

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//elastic-beanstalk?ref=v0.1.6"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    vpc_id                        = "temporary-dummy-id"
    public_subnet_ids             = []
    private_subnet_ids            = []
    vpc_default_security_group_id = ""
  }
}
dependency "bastion" {
  config_path = "../../bastion"
  mock_outputs = {
    security_group_id = ""
  }
}
dependency "rds" {
  config_path = "../../rds"
  mock_outputs = {
    endpoint        = ""
    reader_endpoint = ""
  }
}

# to copy an RDS snapshot between accounts: https://aws.amazon.com/premiumsupport/knowledge-center/rds-snapshots-share-account/
inputs = {
  namespace = "validate"
  stage     = "dev"
  name      = "beanstalk"

  application_description      = "validate"
  vpc_id                       = dependency.vpc.outputs.vpc_id
  public_subnets               = dependency.vpc.outputs.public_subnet_ids
  private_subnets              = dependency.vpc.outputs.private_subnet_ids
  allowed_security_groups      = [dependency.bastion.outputs.security_group_id, dependency.vpc.outputs.vpc_default_security_group_id]
  additional_security_groups   = [dependency.bastion.outputs.security_group_id, dependency.vpc.outputs.vpc_default_security_group_id]
  keypair                      = "dbp-dev"
  description                  = "validate Elastic Beanstalk"
  autoscale_min                = 1
  instance_type                = "t2.micro"

  environment_description = "validate Development environment"
  version_label           = ""
  force_destroy           = true
  root_volume_size        = 2
  root_volume_type        = "gp2"

  rolling_update_enabled  = true
  rolling_update_type     = "Health"
  updating_min_in_service = 0
  updating_max_batch      = 1

  healthcheck_url  = "/hello.php"
  application_port = 80

  solution_stack_name = "64bit Amazon Linux 2018.03 v2.9.21 running PHP 7.2"

  // https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html

}
