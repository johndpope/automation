output "layers" {
  value = {
    xray   = "${aws_lambda_layer_version.xray.arn}"
    moment = "${aws_lambda_layer_version.moment.arn}"
    lodash = "${aws_lambda_layer_version.lodash.arn}"
  }
}
