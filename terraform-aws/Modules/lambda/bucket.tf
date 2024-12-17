# Define the S3 bucket resource
resource "aws_s3_bucket" "bucket_name" {
  bucket = var.bucket_name  # Use the variable for the bucket name
  versioning {
    enabled = true
  }

}
# Upload multiple objects from a directory to the S3 bucket (if need to upload any code)
#resource "aws_s3_bucket_object" "objects" {
#  for_each = fileset("D:/files/sampleimages/", "*")  # Loop through files in the directory

#  bucket = aws_s3_bucket.bucket_name.bucket  # Reference the created S3 bucket
 # key    = each.value                       # Object key (file name)
 # source = "D:/files/sampleimages/${each.value}" # Source path of the file
#  etag   = filemd5("D:/files/sampleimages/${each.value}")  # ETag to ensure correct upload
#}
