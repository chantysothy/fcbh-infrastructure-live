# obt-dev couchbase cluster, based on terraform-aws-couchbase modules

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/terraform-aws-couchbase.git//foobah?ref=v0.1.7"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id            = "temporary-dummy-id"
    bastion_subnet_id = "subnet-id"
  }
}

inputs = {

  namespace    = "obt"
  stage        = "dev"
  name         = "couchbase"
  vpc_id       =  dependency.vpc.outputs.vpc_id
  subnet_ids   = dependency.vpc.outputs.private_subnet_ids
  domain_name  = "biblebrain.com" # temp....need to create the real hosted zone and wildcard certificate first
  load_balancer_certificate_arn = "arn:aws:acm:us-east-1:596282610570:certificate/9ca85cb7-cd09-4996-afc7-b29a4c4bc9f1"
  cluster_name = "render-dev"
  ami_id       = "ami-01433ca69f8d6228d"
  ssh_key_name = "couchbase-render-dev"
  
  # instance_type = "t4g.medium"  
  # vpc_id       = dependency.vpc.outputs.vpc_id
  # control_cidr = ["140.82.163.2/32", "73.26.9.216/32", "45.58.38.254/32", "172.58.62.207/32", "34.215.119.74/32", "73.98.86.246/32", "73.242.135.160/32", 
  # "140.82.163.6/32", "75.150.17.102/32", "184.54.253.73/32",
  # "181.51.191.116/32", "96.64.159.22/32", "68.235.44.73/32", "136.37.119.235/32"  ]
  # key_name     = "couchbase-render-dev"
  # subnet_id    = dependency.vpc.outputs.bastion_subnet_id
}
