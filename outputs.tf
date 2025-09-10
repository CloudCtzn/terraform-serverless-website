# This output displays the public domain name of your CloudFront distribution
# You will use this to update your DNS record in Route 53

output "cloudfront_domain_name" {
	description = "The domain name of the CloudFront distribution."
	value = aws_cloudfront_distribution.s3_distribution.domain_name
}
