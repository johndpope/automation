locals {
  # -----------------------------------------------
  # Project Informations
  # -----------------------------------------------
  remote_init   = "${data.terraform_remote_state.init.outputs}"
  remote_layers = "${data.terraform_remote_state.layers.outputs}"

  project_name    = "${local.remote_init.project_name}"
  project_name_uc = "${local.remote_init.project_name_uc}"
  region          = "${local.remote_init.region}"
  environment     = "${local.remote_init.environment}"
  account_id      = "${data.aws_caller_identity.current.account_id}"
  # -----------------------------------------------
  # Lambda Environments
  # -----------------------------------------------
  dynamodb_tables = "${join(",", local.remote_init.dynamodb_tables)}"
  slack_url       = "${local.remote_init.ssm_param_slack_url}"

  xray   = "${local.remote_layers.layers.xray}"
  moment = "${local.remote_layers.layers.moment}"
  lodash = "${local.remote_layers.layers.lodash}"
  axios  = "${local.remote_layers.layers.axios}"
}

data "aws_caller_identity" "current" {}
