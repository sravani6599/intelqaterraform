#Create the DynamoDB Table
resource "aws_dynamodb_table" "dynamodb_table" {
  name = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "FileName"

  attribute {
    name = "FileName"
    type = "S"
  }
}
# Allow Lambda to Be Invoked by S3
resource "aws_lambda_permission" "allow_s3_invocation" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket_name.arn
}


# Attach Policies to the IAM Role
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-basic-execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# IAM policy for dynamobd and s3 acess
resource "aws_iam_policy" "dynamodb_s3_access" {
  name = "dynamodb-s3-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.dynamodb_table.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.bucket_name.arn,
          "${aws_s3_bucket.bucket_name.arn}/*"
        ]
      }
    ]
  })
}
#Iam policy attachment for dynamodb and s3
resource "aws_iam_policy_attachment" "attach_dynamodb_s3_policy" {
  name       = "attach-dynamodb-s3-policy"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.dynamodb_s3_access.arn
}

# IAM Role for Lambda Function (Optional for S3 -> DynamoDB Integration)
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

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

  # Attach permissions for DynamoDB and S3
  inline_policy {
    name = "s3-dynamodb-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
          Resource = aws_dynamodb_table.dynamodb_table.arn
        },
        {
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:PutObject"]
          Resource = "${aws_s3_bucket.bucket_name.arn}/*"
        }
      ]
    })
  }
}



