
// -----------------------------------------
// AWS Lambda Function
// -----------------------------------------
module "m001" {
  source = "github.com/wwalpha/terraform-module-registry/aws/lambda"

  filename         = "${data.archive_file.m001.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.m001.output_path}")}"

  function_name      = "${local.project_name_uc}-M001"
  handler            = "index.handler"
  runtime            = "nodejs10.x"
  memory_size        = 256
  timeout            = 120
  trigger_principal  = "events.amazonaws.com"
  trigger_source_arn = "${aws_cloudwatch_event_rule.m001.arn}"
  layers             = ["${local.xray}", "${local.moment}"]

  role_name = "${local.project_name_uc}_Lambda_M001Role"
  role_policy_json = [
    "${file("iam/lambda_policy_m001.json")}",
  ]

  variables = {
    CALL_SLACK_FUNCTION = "PocketCards-M003"
    GROUPNAME_PREFIX    = "/aws/lambda/PocketCards"
  }
}

// -----------------------------------------
// Lambda Function Module
// -----------------------------------------
data "archive_file" "m001" {
  type        = "zip"
  source_file = "../build/m001/index.js"
  output_path = "../build/m001/index.zip"
}

# -----------------------------------------------
# Amazon CloudWatch Rule
# -----------------------------------------------
resource "aws_cloudwatch_event_rule" "m001" {
  name        = "${local.project_name_uc}_LambdaErrors"
  description = "Lambda Error"

  schedule_expression = "cron(0/60 23-15 * * ? *)"
}

# -----------------------------------------------
# Amazon CloudWatch Event Target
# -----------------------------------------------
resource "aws_cloudwatch_event_target" "m001" {
  depends_on = ["aws_cloudwatch_event_rule.m001"]

  rule = "${aws_cloudwatch_event_rule.m001.name}"
  arn  = "${module.m001.arn}"
}
