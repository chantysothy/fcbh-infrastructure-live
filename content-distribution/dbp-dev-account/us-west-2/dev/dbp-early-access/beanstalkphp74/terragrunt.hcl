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
  config_path = "../rds"
  mock_outputs = {
    endpoint        = ""
    reader_endpoint = ""
  }
}
dependency "elasticache" {
  config_path = "../elasticache"
  mock_outputs = {
    cluster_address = ""
  }
}
dependency "route53" {
  config_path = "../route53"
  mock_outputs = {
    zone_id = ""
  }
}
dependency "certificate" {
  config_path = "../../certificate/earlyaccess.dev.dbt.io"
  mock_outputs = {
    arn = ""
  }
}

# to copy an RDS snapshot between accounts: https://aws.amazon.com/premiumsupport/knowledge-center/rds-snapshots-share-account/
inputs = {
  namespace = "dbp"
  stage     = "earlyaccessphp74"
  name      = "beanstalk"

  application_description      = "dbp"
  vpc_id                       = dependency.vpc.outputs.vpc_id
  public_subnets               = dependency.vpc.outputs.public_subnet_ids
  private_subnets              = dependency.vpc.outputs.private_subnet_ids
  allowed_security_groups      = [dependency.bastion.outputs.security_group_id, dependency.vpc.outputs.vpc_default_security_group_id]
  additional_security_groups   = [dependency.bastion.outputs.security_group_id, dependency.vpc.outputs.vpc_default_security_group_id]
  keypair                      = "dbp-dev"
  description                  = "DBP Early Access Beanstalk"
  autoscale_min                = 2
  dns_zone_id                  = dependency.route53.outputs.zone_id
  loadbalancer_certificate_arn = dependency.certificate.outputs.arn
  instance_type                = "t3.small"

  environment_description = "DBP Early Access environment with PHP 7.4 solution stack"
  version_label           = ""
  force_destroy           = true
  root_volume_size        = 8
  root_volume_type        = "gp2"

  rolling_update_enabled  = true
  rolling_update_type     = "Health"
  updating_min_in_service = 0
  updating_max_batch      = 1
  preferred_start_time    = "Sun:18:00"

  healthcheck_url  = "/status"
  application_port = 80
  //solution_stack_name = "64bit Amazon Linux 2018.03 v2.9.12 running PHP 7.2"
  //solution_stack_name = "64bit Amazon Linux 2018.03 v2.9.15 running PHP 7.3"
  solution_stack_name = "64bit Amazon Linux 2 v3.2.0 running PHP 7.4"
  enable_stream_logs  = true

  // https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html

  env_vars = {
    "BEANSTALK_BUCKET"   = "elasticbeanstalk-us-west-2-078432969830"
    "S3_CONFIG_LOC"      = "https://s3-us-west-2.amazonaws.com/elasticbeanstalk-us-west-2-078432969830/dbp-early-access"
    "APP_ENV"            = "dev"
    "APP_URL"            = "https://earlyaccess.dev.dbt.io"
    "API_URL"            = "https://earlyaccess.dev.dbt.io/api"
    "APP_URL_PODCAST"    = "https://earlyaccess.dev.dbt.io"
    "APP_DEBUG"          = "1"
    "DBP_HOST"           = dependency.rds.outputs.reader_endpoint
    "DBP_DATABASE"       = "dbp_210203"
    "DBP_USERNAME"       = "api_node_dbp"
    "DBP_USERS_HOST"     = dependency.rds.outputs.endpoint
    "DBP_USERS_DATABASE" = "dbp_users"
    "DBP_USERS_USERNAME" = "api_node_dbp"
    "MEMCACHED_HOST"     = dependency.elasticache.outputs.cluster_address
    "NEW_RELIC_APP_NAME" = "DBP4 EA"
  }
}