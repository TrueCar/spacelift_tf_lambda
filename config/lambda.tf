resource "aws_lambda_function" "spacelift" {
  filename         = "${path.module}/../src/lambda.zip"
  function_name    = var.name
  role             = aws_iam_role.spacelift.arn
  handler          = "spacelift.lambda_handler"
  runtime          = "ruby2.7"
  timeout          = 10
  memory_size      = 128
  description      = "Spacelift poc"
  source_code_hash = filebase64sha256("${path.module}/../src/spacelift.rb")

  vpc_config {
    security_group_ids = [var.security_group_id]
    subnet_ids         = [var.subnet_id]
  }

  tags = local.default_tags
}
