# CloudWatch Log Group for storing logs
resource "aws_cloudwatch_log_group" "cognito_group" {
  name              = var.log_group_name
  retention_in_days = 30  # Retain logs for 7 days
  
}

# Attach the necessary policy for CloudWatch Logs
resource "aws_iam_policy_attachment" "lambda_logging_policy" {
  name       = "lambda-logging-policy"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# CloudWatch Event Rule that fires every 5 minutes
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name        = "every-five-minutes"
  description = "Fires every five minutes"
  schedule_expression = "rate(5 minutes)"
}

# CloudWatch Event Target to lambda (lambda function)
resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambda.arn
}

# Lambda Permission to allow CloudWatch Events to invoke the Lambda function
resource "aws_lambda_permission" "cloudwatch_permission" {
  statement_id = "AllowExecutionFromCloudWatch"
  action       = "lambda:InvokeFunction"
  function_name = "${var.function_name}"
  principal    = "events.amazonaws.com"
  source_arn   = aws_cloudwatch_event_rule.every_five_minutes.arn
  #depends_on    = [aws_lambda_function.lambda]
}


# IAM Role for Lambda to write logs to CloudWatch Logs
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy to allow Lambda to write logs to CloudWatch Logs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:*"
        Resource = "*"
      }
    ]
  })
}
#This IAM role allows Cognito to write logs to CloudWatch
resource "aws_iam_role" "cognito_log_role" {
  name = "CognitoCloudWatchLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cognito-idp.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
# this iam policy allows cognito to write logs
resource "aws_iam_policy" "cognito_log_policy" {
  name        = "CognitoLogPolicy"
  description = "Policy for Cognito to write logs to CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cognito_group.arn}:*"
      }
    ]
  })
}
#attachment of the log policy
resource "aws_iam_role_policy_attachment" "attach_log_policy" {
  role       = aws_iam_role.cognito_log_role.name
  policy_arn = aws_iam_policy.cognito_log_policy.arn
}




