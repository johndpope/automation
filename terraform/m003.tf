module "m003" {
  source = "github.com/wwalpha/terraform-module-registry/aws/lambda"

  filename         = "${data.archive_file.m003.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.m003.output_path}")}"

  function_name    = "${local.project_name_uc}-M003"
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  role_name        = "${local.project_name_uc}_Lambda_M003Role"
  layers           = ["${local.xray}", "${local.axios}"]
  role_policy_json = ["${file("iam/lambda_policy_m003.json")}"]

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
  source_file = "../build/m003/index.js"
  output_path = "../build/m003/index.zip"
}
