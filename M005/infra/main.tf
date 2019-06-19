// -----------------------------------------
// Backend
// -----------------------------------------
terraform {
  backend "s3" {
    bucket = "terraform-backend-xxx"
    region = "ap-northeast-1"
    key    = "pocket-cards/automation_M005.tfstate"
  }

  required_version = ">= 0.12"
}


module "this" {
  source = "github.com/wwalpha/terraform-modules-lambda"

  filename         = "${data.archive_file.this.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.this.output_path}")}"

  function_name    = "${local.project_name_uc}-M005"
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  role_name        = "${local.project_name_uc}-M005"
  layers           = ["${local.xray}"]
  role_policy_json = ["${data.aws_iam_policy_document.lambda.json}"]

  trigger_principal  = "events.amazonaws.com"
  trigger_source_arn = "${aws_cloudwatch_event_rule.this.arn}"

  variables = {
    CALL_SLACK_FUNCTION = "PocketCards-M005"
  }

  timeout = 5
}

# ------------------------------
# AWS Role Policy
# ------------------------------
data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}
