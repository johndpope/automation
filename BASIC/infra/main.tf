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

# module "slack" {
#   source = "github.com/wwalpha/terraform-modules-lambda"

#   file_name = "build/index.zip"

#   function_name = "${local.project_name_uc}-M001"
#   handler       = "index.handler"
#   runtime       = "nodejs10.x"
#   role_name     = "${local.project_name_uc}-M001"
#   # role_policy_json = ["${data.aws_iam_policy_document.dynamodb_access_policy.json}"]

#   timeout = 5
# }
