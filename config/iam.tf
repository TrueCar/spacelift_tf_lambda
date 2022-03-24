resource "aws_iam_role" "spacelift" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json

  tags = local.default_tags
}

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "spacelift" {
  role   = aws_iam_role.spacelift.id
  name   = var.name
  policy = data.aws_iam_policy_document.spacelift.json
}

data "aws_iam_policy_document" "spacelift" {
  statement {
    actions = ["sts:AssumeRole"]

    resources = ["arn:aws:iam::*:role/assume/admin/*"]
  }

  statement {
    actions = ["secretsmanager:GetSecretValue"]

    resources = ["arn:aws:secretsmanager:us-west-2:213162591021:secret:*"]
  }
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.spacelift.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_policy_2" {
  role       = aws_iam_role.spacelift.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
