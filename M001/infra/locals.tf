locals {
  # -----------------------------------------------
  # Project Informations
  # -----------------------------------------------
  remote_outputs = "${data.terraform_remote_state.init.outputs}"

  project_name    = "${local.remote_outputs.project_name}"
  project_name_uc = "${local.remote_outputs.project_name_uc}"
  region          = "${local.remote_outputs.region}"
  environment     = "${local.remote_outputs.environment}"
}
