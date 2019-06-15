

module "slack" {
  source = "github.com/wwalpha/terraform-modules-lambda"

  function_name = "${local.project_name_uc}-M001"
  handler       = "index.handler"
  runtime       = "nodejs10.x"
  role_name     = "${local.project_name_uc}-M001"
  # role_policy_json = ["${data.aws_iam_policy_document.dynamodb_access_policy.json}"]
  use_dummy_file = true
  timeout        = 5
}
