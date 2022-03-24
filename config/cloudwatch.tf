resource "aws_cloudwatch_event_rule" "spacelift" {
  name                = "spacelift_poc_rule"
  description         = "Spacelift poc rule"
  schedule_expression = "cron(0 8 * * ? *)"

  tags = local.default_tags
}

resource "aws_cloudwatch_event_target" "spacelift" {
  arn  = aws_lambda_function.spacelift.arn
  rule = aws_cloudwatch_event_rule.spacelift.id
}
