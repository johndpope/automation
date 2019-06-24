module "m003" {
  source = "github.com/wwalpha/terraform-modules-lambda"

  filename         = "${data.archive_file.m003.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.m003.output_path}")}"

  function_name    = "${local.project_name_uc}-M003"
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  role_name        = "${local.project_name_uc}-M003"
  layers           = ["${local.xray}", "${local.axios}"]
  role_policy_json = ["${data.aws_iam_policy_document.m003_ssm_policy.json}"]

  variables = {
    SLACK_URL_KEY = "${local.slack_url}"
  }
  timeout = 5
}


// -----------------------------------------
// Lambda Module File
// -----------------------------------------
data "archive_file" "m003" {
  type        = "zip"
  source_file = "build/index.js"
  output_path = "build/index.zip"
}

// -----------------------------------------
// AWS IAM SSM Policy
// -----------------------------------------
data "aws_iam_policy_document" "m003_ssm_policy" {
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


