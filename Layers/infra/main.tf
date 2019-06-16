// -----------------------------------------
// Backend
// -----------------------------------------
terraform {
  backend "s3" {
    bucket = "terraform-backend-xxx"
    region = "ap-northeast-1"
    key    = "pocket-cards/layers.tfstate"
  }

  required_version = ">= 0.12"
}


// -----------------------------------------
// aws-xray-sdk
// -----------------------------------------
data "archive_file" "xray" {
  type = "zip"

  source_dir  = "build/xray"
  output_path = "build/xray/nodejs.zip"
}

resource "aws_lambda_layer_version" "xray" {
  layer_name = "aws-xray-sdk"

  filename         = "${data.archive_file.xray.output_path}"
  source_code_hash = "${base64sha256(filebase64("${data.archive_file.xray.output_path}"))}"

  compatible_runtimes = ["nodejs8.10", "nodejs10.x"]
}

// -----------------------------------------
// moment
// -----------------------------------------
data "archive_file" "moment" {
  type = "zip"

  source_dir  = "build/moment"
  output_path = "build/moment/nodejs.zip"
}

resource "aws_lambda_layer_version" "moment" {
  layer_name = "moment"

  filename         = "${data.archive_file.moment.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.moment.output_path}")}"

  compatible_runtimes = ["nodejs8.10", "nodejs10.x"]
}

// -----------------------------------------
// lodash
// -----------------------------------------
data "archive_file" "lodash" {
  type = "zip"

  source_dir  = "build/lodash"
  output_path = "build/lodash/nodejs.zip"
}

resource "aws_lambda_layer_version" "lodash" {
  layer_name = "lodash"

  filename         = "${data.archive_file.lodash.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.lodash.output_path}")}"

  compatible_runtimes = ["nodejs8.10", "nodejs10.x"]
}
