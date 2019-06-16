// -----------------------------------------
// Provider
// -----------------------------------------
provider "aws" {
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.aws_profile}"
  region                  = "${local.region}"
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

data "terraform_remote_state" "layers" {
  backend = "s3"

  config = {
    bucket = "terraform-backend-xxx"
    region = "ap-northeast-1"
    key    = "pocket-cards/layers.tfstate"
  }
}

// -----------------------------------------
// Lambda Module File
// -----------------------------------------
data "archive_file" "this" {
  type        = "zip"
  source_file = "build/index.js"
  output_path = "build/index.zip"
}
