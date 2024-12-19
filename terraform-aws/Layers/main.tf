provider "aws" {
    access_key = "${var.aws_access_key_id}"
    secret_key = "${var.aws_secret_access_key}"
    region = "${var.aws_region}"
}

#module "secrets" {
 # source = "../Modules/secrets"

  #aws_access_key = var.aws_access_key
  #aws_secret_key = var.aws_secret_key
#}

module "lambda"{
    source = "../Modules/lambda"
    function_name =  "intellambda"
    bucket_name = "ai2024intelbucketqa" 
    user_pool = "intelqauserpool"
    table_name = "dynamodbtables3"
    log_group_name = "/aws/cognito/user-pool-logs"
   # bucket_object = "D:/files/sampleimages/"

    
}
#module "bedrock"{
 #   source = "../Modules/bedrock"
  #  function_name = "bedrock-lambda"
#}
