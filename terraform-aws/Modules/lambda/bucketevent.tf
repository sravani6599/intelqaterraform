
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket =  "${var.bucket_name}" 

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.bucket_name]
}
resource "aws_lambda_permission" "bucket_name" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${var.function_name}" 
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket_name.arn
}

