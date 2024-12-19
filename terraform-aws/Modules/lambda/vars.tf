variable "bucket_name" {
  type    = string
  default = "bucket_name"  # Replace with your desired bucket name
}
    
variable "function_name" {
    default = "lambda_function"
}

variable "table_name" {
  default = "dynamodb-table"
}
variable "lambda_function_arn"{
    default = "aws_lambda_function.lambda.arn"
}

variable "acl_value" {
    default = "private"
}

variable "region"{
    default = "region"

}
variable "user_pool"{
    default = "name of the userpool"
}


variable "log_group_name" {
  default = "log_group"
}

#variable "bucket_object"{
  #default = " path for the object"

#}
variable "lambda_logging_policy" {
  default = "name of the policy"
  
}

