// -----------------------------------------
// Lambda Module File
// -----------------------------------------
data "archive_file" "m005" {
  type        = "zip"
  source_file = "build/index.js"
  output_path = "build/index.zip"
}

module "m005" {
  source = "github.com/wwalpha/terraform-modules-lambda"

  filename         = "${data.archive_file.m005.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.m005.output_path}")}"

  enable_xray      = true
  function_name    = "${local.project_name_uc}-M005"
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  role_name        = "${local.project_name_uc}-M005"
  layers           = ["${local.xray}"]
  role_policy_json = ["${data.aws_iam_policy_document.m005_lambda.json}"]

  trigger_principal  = "events.amazonaws.com"
  trigger_source_arn = "${aws_cloudwatch_event_rule.m005.arn}"

  variables = {
    CALL_SLACK_FUNCTION = "PocketCards-M003"
  }

  timeout = 5
}

# ------------------------------
# AWS Role Policy
# ------------------------------
data "aws_iam_policy_document" "m005_lambda" {
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

# -----------------------------------------------
# Amazon CloudWatch Rule
# -----------------------------------------------
resource "aws_cloudwatch_event_rule" "m005" {
  name        = "${local.project_name_uc}_CodePipelineSuccess"
  description = "CodePipeline State Success Rule"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codepipeline"
  ],
  "detail-type": [
    "CodePipeline Pipeline Execution State Change"
  ],
  "detail": {
    "state": [
      "SUCCEEDED"
    ]
  }
}
PATTERN
}
# -----------------------------------------------
# Amazon CloudWatch Event Target
# -----------------------------------------------
resource "aws_cloudwatch_event_target" "m005" {
  depends_on = ["aws_cloudwatch_event_rule.m005"]

  rule = "${aws_cloudwatch_event_rule.m005.name}"
  arn = "${module.m005.arn}"
}

