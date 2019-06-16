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

  filename         = "${data.archive_file.this.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.this.output_path}")}"

  function_name    = "${local.project_name_uc}-M002"
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  role_name        = "${local.project_name_uc}-M002"
  layers           = ["${local.xray}", "${local.lodash}", "${local.moment}"]
  role_policy_json = ["${data.aws_iam_policy_document.dynamodb_policy.json}"]

  variables = {
    TABLES             = "${local.dynamodb_tables}"
    BACKUP_GENERATIONS = 7
  }
  timeout = 5
}

data "aws_iam_policy_document" "dynamodb_policy" {
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


