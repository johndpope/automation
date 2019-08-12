locals {
  # -----------------------------------------------
  # Project Informations
  # -----------------------------------------------
  remote_init = "${data.terraform_remote_state.initialize.outputs}"
  remote_unmu = "${data.terraform_remote_state.unmutable.outputs}"

  project_name    = "${local.remote_init.project_name}"
  project_name_uc = "${local.remote_init.project_name_uc}"
  region          = "${data.aws_region.this.name}"
  environment     = "${terraform.workspace}"
  account_id      = "${data.aws_caller_identity.this.account_id}"
  # -----------------------------------------------
  # Lambda Environments
  # -----------------------------------------------
  dynamodb_tables = "${join(",", local.remote_unmu.dynamodb_tables)}"
  slack_url       = "${local.remote_init.ssm_param_slack_url}"

  xray   = "${local.remote_init.layers.xray}"
  moment = "${local.remote_init.layers.moment}"
  lodash = "${local.remote_init.layers.lodash}"
  axios  = "${local.remote_init.layers.axios}"
}
# -----------------------------------------------
# AWS Account
# -----------------------------------------------
data "aws_caller_identity" "this" {}
# -----------------------------------------------
# AWS Region
# -----------------------------------------------
data "aws_region" "this" {}
