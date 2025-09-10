# The 's3_bucket_name' variable allows you to set the S3 bucket's name 
# when you run 'terraform apply', so the code remains flexible 
variable "s3_bucket_name" {
	description = "The name of the S3 bucket. Must be globally unique."
	type = string
}
