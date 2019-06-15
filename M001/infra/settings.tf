// -----------------------------------------
// Provider
// -----------------------------------------
provider "aws" {
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.aws_profile}"
  region                  = "${local.region}"
  version                 = "2.10.0"
}

// -----------------------------------------
// Backend
// -----------------------------------------
terraform {
  backend "s3" {
    bucket = "terraform-backend-xxx"
    region = "ap-northeast-1"
    key    = "pocket-cards/automation_M001.tfstate"
  }

  required_version = ">= 0.12"
}

// -----------------------------------------
// Project Information
// -----------------------------------------
data "terraform_remote_state" "init" {
  backend = "s3"

  config = {
    bucket = "terraform-backend-xxx"
    region = "ap-northeast-1"
    key    = "pocket-cards/init.tfstate"
  }
}

// -----------------------------------------
// Lambda Module File
// -----------------------------------------
data "archive_file" "module" {
  type        = "zip"
  source_file = "${path.module}/build/index.js"
  output_path = "${path.module}/build/index.zip"
}
