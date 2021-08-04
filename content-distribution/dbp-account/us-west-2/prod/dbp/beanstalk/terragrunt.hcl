# member-account: dbp

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
#dependency "rds" {
#  config_path = "../../rds"
#  mock_outputs = {
#      endpoint = ""
#      reader_endpoint = ""
#  }  
#}
dependency "elasticache" {
  config_path = "../../elasticache"
  mock_outputs = {
    cluster_address = ""
  }
}
dependency "route53" {
  config_path = "../../route53"
  mock_outputs = {
    zone_id = ""
  }
}
dependency "certificate" {
  config_path = "../../certificate/dbt.io"
  mock_outputs = {
    arn = ""
  }
}

# to copy an RDS snapshot between accounts: https://aws.amazon.com/premiumsupport/knowledge-center/rds-snapshots-share-account/
inputs = {
  namespace                  = "dbp"
  stage                      = ""
  name                       = "beanstalk"

  application_description    = "dbp"
  vpc_id                     = dependency.vpc.outputs.vpc_id
  public_subnets             = dependency.vpc.outputs.public_subnet_ids
  private_subnets            = dependency.vpc.outputs.private_subnet_ids
  allowed_security_groups    = [dependency.bastion.outputs.security_group_id, dependency.vpc.outputs.vpc_default_security_group_id]
  additional_security_groups = [dependency.bastion.outputs.security_group_id, dependency.vpc.outputs.vpc_default_security_group_id]
  keypair                    = "dbp"
  description                = "DBP Elastic Beanstalk "
  preferred_start_time       = "MON:18:00"  
  autoscale_min              = 3
  autoscale_max              = 12
  autoscale_lower_bound      = 30 # scale in when CPU < 30% (referencing default values for other settings)
  autoscale_upper_bound      = 60 # scale out when CPU > 60%
  dns_zone_id                = dependency.route53.outputs.zone_id
  loadbalancer_certificate_arn = dependency.certificate.outputs.arn
  instance_type              = "t3.medium"

  environment_description    = "DBP Production Beanstalk"

  healthcheck_url            = "/status"
  enable_stream_logs         = true

  solution_stack_name        = "64bit Amazon Linux 2018.03 v2.9.21 running PHP 7.2"

  env_vars = {
    "BEANSTALK_BUCKET"    = "elasticbeanstalk-us-west-2-596282610570"
    "S3_CONFIG_LOC"      = "https://s3-us-west-2.amazonaws.com/elasticbeanstalk-us-west-2-596282610570/dbp"    
    "APP_ENV"            = "prod"
    "APP_URL"            = "https://4.dbt.io"
    "API_URL"            = "https://4.dbt.io/api"
    "APP_URL_PODCAST"    = "https://4.dbt.io"
    "APP_DEBUG"          = "0"
    "DBP_HOST"           = "prod-cluster-restored-june23-cluster.cluster-ro-cp6dghsmdxd5.us-west-2.rds.amazonaws.com"
    "DBP_DATABASE"       = "dbp_210716"
    "DBP_USERNAME"       = "api_node_dbp"
    "DBP_USERS_HOST"     = "prod-cluster-restored-june23-cluster.cluster-cp6dghsmdxd5.us-west-2.rds.amazonaws.com"
    "DBP_USERS_DATABASE" = "dbp_users"
    "DBP_USERS_USERNAME" = "api_node_dbp"
    "MEMCACHED_HOST"     = dependency.elasticache.outputs.cluster_address
    "NEW_RELIC_APP_NAME" = "DBP4 PROD"
  }
}
