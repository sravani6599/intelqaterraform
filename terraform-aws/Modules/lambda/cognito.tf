# Data source to fetch the current AWS region
data "aws_region" "current" {}

# Create Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool
  password_policy {
    minimum_length = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers = true
    require_symbols = true
  }

  mfa_configuration = "OFF"

  auto_verified_attributes = ["email"]

}

# Create Cognito User Pool Client (for your app to interact with the User Pool)
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "my-user-pool-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  

  generate_secret = true
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  
}

# Create Cognito Identity Pool (to enable federated identities)
resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name = "my-identity-pool"
  allow_unauthenticated_identities = true  # Set to false if you don't want unauthenticated users

  depends_on = [aws_cognito_user_pool.user_pool]
}

# Create IAM roles for authenticated and unauthenticated users
resource "aws_iam_role" "authenticated_role" {
  name = "Cognito_${aws_cognito_identity_pool.identity_pool.identity_pool_name}_Auth_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Effect    = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.identity_pool.id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "unauthenticated_role" {
  name = "Cognito_${aws_cognito_identity_pool.identity_pool.identity_pool_name}_Unauth_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Effect    = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.identity_pool.id
          }
        }
      }
    ]
  })
}

# Attach the roles to the identity pool
resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles_attachment" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  roles = {
    "authenticated"   = aws_iam_role.authenticated_role.arn
    "unauthenticated" = aws_iam_role.unauthenticated_role.arn
  }
}

# Output the user pool and identity pool IDs
output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.identity_pool.id
}


