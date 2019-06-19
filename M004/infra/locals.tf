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

  # -----------------------------------------------
  # Lambda Environments
  # -----------------------------------------------
  dynamodb_tables = "${join(",", local.remote_init.dynamodb_tables)}"

  xray   = "${local.remote_layers.layers.xray}"
  moment = "${local.remote_layers.layers.moment}"
  lodash = "${local.remote_layers.layers.lodash}"
  axios  = "${local.remote_layers.layers.axios}"
}
