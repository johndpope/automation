
// -----------------------------------------
// AWS Lambda Function
// -----------------------------------------
module "m001" {
  source = "github.com/wwalpha/terraform-modules-lambda"

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

  role_name = "${local.project_name_uc}-M001Role"
  role_policy_json = [
    "${data.aws_iam_policy_document.m001_lambda.json}",
    "${data.aws_iam_policy_document.m001_cloudwatch.json}"
  ]

  variables = {
    CALL_SLACK_FUNCTION = "PocketCards-M003"
    GROUPNAME_PREFIX    = "/aws/lambda/PocketCards"
  }
}


# ------------------------------
# AWS Role Policy
# ------------------------------
data "aws_iam_policy_document" "m001_lambda" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "m001_cloudwatch" {
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:StartQuery"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:*",
    ]
  }

  statement {
    actions = [
      "logs:GetQueryResults",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
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

  schedule_expression = "cron(0/15 23-15 * * ? *)"
}

# -----------------------------------------------
# Amazon CloudWatch Event Target
# -----------------------------------------------
resource "aws_cloudwatch_event_target" "m001" {
  depends_on = ["aws_cloudwatch_event_rule.m001"]

  rule = "${aws_cloudwatch_event_rule.m001.name}"
  arn  = "${module.m001.arn}"
}



# // -----------------------------------------
# // AWS SNS Topic
# // -----------------------------------------
# resource "aws_sns_topic" "m001" {
#   name                                     = "${local.project_name_uc}_LambdaError"
#   application_success_feedback_sample_rate = 0
#   http_success_feedback_sample_rate        = 0
#   sqs_success_feedback_sample_rate         = 0

#   policy = "${data.aws_iam_policy_document.m001_sns.json}"
# }


# // -----------------------------------------
# // AWS SNS Topic Policy
# // -----------------------------------------
# data "aws_iam_policy_document" "m001_sns" {
#   statement {
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }

#     effect = "Allow"

#     actions = [
#       "SNS:GetTopicAttributes",
#       "SNS:SetTopicAttributes",
#       "SNS:AddPermission",
#       "SNS:RemovePermission",
#       "SNS:DeleteTopic",
#       "SNS:Subscribe",
#       "SNS:ListSubscriptionsByTopic",
#       "SNS:Publish",
#       "SNS:Receive",
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceOwner"

#       values = [
#         "${local.account_id}",
#       ]
#     }

#     resources = [
#       "arn:aws:sns:${local.region}:${local.account_id}:*",
#     ]
#   }
# }

# // -----------------------------------------
# // AWS Lambda Function
# // -----------------------------------------
# module "m001" {
#   source = "github.com/wwalpha/terraform-modules-lambda"

#   filename         = "${data.archive_file.m001.output_path}"
#   source_code_hash = "${filebase64sha256("${data.archive_file.m001.output_path}")}"

#   function_name      = "${local.project_name_uc}-M001"
#   handler            = "index.handler"
#   runtime            = "nodejs10.x"
#   memory_size        = 512
#   timeout            = 120
#   trigger_principal  = "sns.amazonaws.com"
#   trigger_source_arn = "${aws_sns_topic.m001.arn}"
#   layers             = ["${local.xray}", "${local.moment}"]

#   role_name = "${local.project_name_uc}-M001Role"
#   role_policy_json = [
#     "${data.aws_iam_policy_document.m001_lambda.json}",
#     "${data.aws_iam_policy_document.m001_cloudwatch.json}"
#   ]

#   variables = {
#     CALL_SLACK_FUNCTION = "PocketCards-M003"
#     GROUPNAME_PREFIX    = "/aws/lambda/PocketCards"
#   }
# }

# # ------------------------------
# # AWS Role Policy
# # ------------------------------
# data "aws_iam_policy_document" "m001_lambda" {
#   statement {
#     actions = [
#       "lambda:InvokeFunction",
#     ]

#     effect = "Allow"

#     resources = [
#       "*",
#     ]
#   }
# }

# data "aws_iam_policy_document" "m001_cloudwatch" {
#   statement {
#     actions = [
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#       "logs:StartQuery"
#     ]

#     effect = "Allow"

#     resources = [
#       "arn:aws:logs:${local.region}:${local.account_id}:log-group:*",
#     ]
#   }

#   statement {
#     actions = [
#       "logs:GetQueryResults",
#     ]

#     effect = "Allow"

#     resources = [
#       "*",
#     ]
#   }
# }

# // -----------------------------------------
# // Lambda Function Module
# // -----------------------------------------
# data "archive_file" "m001" {
#   type        = "zip"
#   source_file = "../build/m001/index.js"
#   output_path = "../build/m001/index.zip"
# }

# // -----------------------------------------
# // AWS CloudWatch Metric Alarm
# // -----------------------------------------
# resource "aws_cloudwatch_metric_alarm" "m001" {
#   depends_on = ["aws_sns_topic.m001"]

#   alarm_name          = "${local.project_name_uc}-LambdaErrors"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "Errors"
#   namespace           = "AWS/Lambda"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "1"
#   alarm_description   = "This metric monitors ec2 cpu utilization"
#   datapoints_to_alarm = 1

#   alarm_actions = [
#     "${aws_sns_topic.m001.arn}",
#   ]
#   insufficient_data_actions = []
#   ok_actions                = []
# }

# // -----------------------------------------
# // AWS SNS Topic SubScription - Lambda
# // -----------------------------------------
# resource "aws_sns_topic_subscription" "m001" {
#   depends_on = ["aws_sns_topic.m001"]

#   topic_arn = "${aws_sns_topic.m001.arn}"
#   protocol  = "lambda"
#   endpoint  = "${module.m001.arn}"
# }
