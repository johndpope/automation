
module "m002" {
  source = "github.com/wwalpha/terraform-modules-lambda"

  filename         = "${data.archive_file.m002.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.m002.output_path}")}"

  function_name    = "${local.project_name_uc}-M002"
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  role_name        = "${local.project_name_uc}-M002Role"
  layers           = ["${local.xray}", "${local.lodash}", "${local.moment}"]
  role_policy_json = ["${data.aws_iam_policy_document.m002_dynamodb_policy.json}"]

  variables = {
    TABLES             = "${local.dynamodb_tables}"
    BACKUP_GENERATIONS = 7
  }
  timeout = 5
}


// -----------------------------------------
// Lambda Module File
// -----------------------------------------
data "archive_file" "m002" {
  type        = "zip"
  source_file = "../build/m002/index.js"
  output_path = "../build/m002/index.zip"
}

// -----------------------------------------
// Lambda Module File
// -----------------------------------------
data "aws_iam_policy_document" "m002_dynamodb_policy" {
  statement {
    actions = [
      "dynamodb:DeleteBackup",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:dynamodb:${local.region}:*:table/*/backup/*",
    ]
  }

  statement {
    actions = [
      "dynamodb:CreateBackup",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:dynamodb:${local.region}:*:table/*",
    ]
  }

  statement {
    actions = [
      "dynamodb:ListBackups",
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
resource "aws_cloudwatch_event_rule" "m002" {
  name        = "${local.project_name_uc}_DynamoBackup"
  description = "DynamoDB Table 定時バックアップ"

  schedule_expression = "cron(0 15 * * ? *)"
}

# -----------------------------------------------
# Amazon CloudWatch Event Target
# -----------------------------------------------
resource "aws_cloudwatch_event_target" "m002" {
  depends_on = ["aws_cloudwatch_event_rule.m002"]

  rule = "${aws_cloudwatch_event_rule.m002.name}"
  arn  = "${module.m002.arn}"
}

