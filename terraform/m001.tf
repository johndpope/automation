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

# // -----------------------------------------
# // Lambda Module File
# // -----------------------------------------
# data "archive_file" "module" {
#   type        = "zip"
#   source_file = "${path.module}/build/index.js"
#   output_path = "${path.module}/build/index.zip"
# }
