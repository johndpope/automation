# -----------------------------------------------
# Amazon CloudWatch Rule
# -----------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
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

