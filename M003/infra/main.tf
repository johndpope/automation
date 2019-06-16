// -----------------------------------------
// Backend
// -----------------------------------------
terraform {
  backend "s3" {
    bucket = "terraform-backend-xxx"
    region = "ap-northeast-1"
    key    = "pocket-cards/automation_M003.tfstate"
  }

  required_version = ">= 0.12"
}

module "this" {
  source = "github.com/wwalpha/terraform-modules-lambda"

  filename         = "${data.archive_file.this.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.this.output_path}")}"

  function_name    = "${local.project_name_uc}-M003"
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  role_name        = "${local.project_name_uc}-M003"
  layers           = ["${local.xray}", "${local.axios}"]
  role_policy_json = ["${data.aws_iam_policy_document.ssm_policy.json}"]

  variables = {
    PROJECT_NAME  = "${local.project_name}"
    SLACK_URL_KEY = "slack_url"
  }
  timeout = 5
}

data "aws_iam_policy_document" "ssm_policy" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:ssm:*:*:parameter/*",
    ]
  }
}


