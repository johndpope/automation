// -----------------------------------------
// Backend
// -----------------------------------------
terraform {
  backend "s3" {
    bucket = "terraform-backend-xxx"
    region = "ap-northeast-1"
    key    = "pocket-cards/automation_M002.tfstate"
  }

  required_version = ">= 0.12"
}

module "this" {
  source = "github.com/wwalpha/terraform-modules-lambda"

  # file_name = "build/index.zip"

  function_name = "${local.project_name_uc}-M002"
  handler       = "index.handler"
  runtime       = "nodejs10.x"
  role_name     = "${local.project_name_uc}-M002"
  # role_policy_json = ["${data.aws_iam_policy_document.dynamodb_policy.json}"]

  use_dummy_file = true
  timeout        = 5
}

data "aws_iam_policy_document" "dynamodb_policy" {

}


