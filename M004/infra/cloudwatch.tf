# -----------------------------------------------
# Amazon CloudWatch Rule
# -----------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  name        = "${local.project_name_uc}_CodeBuildError"
  description = "CodeBuild State Error Rule"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codebuild"
  ],
  "detail-type": [
    "CodeBuild Build State Change"
  ],
  "detail": {
    "build-status": [
      "FAILED"
    ]
  }
}
PATTERN
}
# "project-name": [
#   "my-demo-project-1",
#   "my-demo-project-2"
# ]

# -----------------------------------------------
# Amazon CloudWatch Event Target
# -----------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  depends_on = ["aws_cloudwatch_event_rule.this"]

  rule = "${aws_cloudwatch_event_rule.this.name}"
  arn = "${module.this.arn}"
}

