

# Step 2: Create an AWS Secrets Manager secret
resource "aws_secretsmanager_secret" "aws_credentials" {
  name        = "aws_access_credentials" # Name of the secret
  description = "This secret stores AWS access key and secret key"
}

# Step 3: Store secret values (access and secret keys) in the secret
resource "aws_secretsmanager_secret_version" "aws_credentials_version" {
  secret_id     = aws_secretsmanager_secret.aws_credentials.id
  secret_string = jsonencode({
    access_key = var.aws_access_key # Replace with your variable or hardcoded value
    secret_key = var.aws_secret_key # Replace with your variable or hardcoded value
  })
}

# Step 4: Define sensitive variables for access key and secret key
