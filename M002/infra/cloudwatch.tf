# -----------------------------------------------
# Amazon CloudWatch Rule
# -----------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  name        = "${local.project_name_uc}_DynamoBackup"
  description = "DynamoDB Table 定時バックアップ"

  schedule_expression = "cron(0 15 * * ? *)"
}

# -----------------------------------------------
# Amazon CloudWatch Event Target
# -----------------------------------------------
resource "aws_cloudwatch_event_target" "lambda" {
  depends_on = ["aws_cloudwatch_event_rule.this"]

  rule = "${aws_cloudwatch_event_rule.this.name}"
  arn  = "${module.this.arn}"
}

