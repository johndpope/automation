# -----------------------------------------
# Automation
# -----------------------------------------
terraform {
  backend "s3" {
    bucket = "terraform-workspaces"
    region = "ap-northeast-1"
    key    = "pocket-cards/automation.tfstate"
  }

  required_version = ">= 0.12"
}

# -----------------------------------------
# AWS Provider
# -----------------------------------------
provider "aws" {}

# -----------------------------------------------
# Remote state - Initialize
# -----------------------------------------------
data "terraform_remote_state" "initialize" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "terraform-workspaces"
    region = "ap-northeast-1"
    key    = "pocket-cards/initialize.tfstate"
  }
}

# -----------------------------------------------
# Remote state - Unmutable
# -----------------------------------------------
data "terraform_remote_state" "unmutable" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "terraform-workspaces"
    region = "ap-northeast-1"
    key    = "pocket-cards/unmutable.tfstate"
  }
}

