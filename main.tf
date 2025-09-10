# This 'terraform' block configures Terraform itself.
# It declares the providers required for this configuration.
terraform {
  required_providers {
    # The 'aws' provider is for interacting with Amazon Web Services.
    # It is good practice to lock the provider version to prevent unexpected changes.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# This 'provider' block configures the AWS provider with your chosen region.
# Terraform will use your AWS CLI configuration for authentication.
provider "aws" {
  region = "us-east-1" # The region where your resources will be deployed.
}

# -----------------------------------------------------------------------------
# S3 BUCKET & SECURITY CONFIGURATION
# -----------------------------------------------------------------------------

# This resource creates the S3 bucket where your website files will be stored.
# The bucket name is set by a variable to ensure it is unique.
resource "aws_s3_bucket" "cloud_ctzn_website" {
  bucket = var.s3_bucket_name

  # Tags are key-value pairs that help you organize and manage your AWS resources.
  tags = {
    Name        = "CloudCtzn-Portfolio-Website"
    Environment = "production"
  }
}

# This is a critical security resource. It blocks all public access to the S3 bucket.
# This prevents unauthorized access to your website's files directly through S3.
resource "aws_s3_bucket_public_access_block" "static_website_public_access_block" {
  bucket = aws_s3_bucket.cloud_ctzn_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# This resource creates a special identity for CloudFront to securely access the S3 bucket.
# This is a best practice for security, as it avoids making your bucket publicly accessible.
resource "aws_cloudfront_origin_access_identity" "portfolio_oai" {
  comment = "OAI for the CloudCtzn portfolio website S3 bucket"
}

# This bucket policy allows the CloudFront OAI (but no one else) to read objects from the S3 bucket.
resource "aws_s3_bucket_policy" "portfolio_policy" {
  bucket = aws_s3_bucket.cloud_ctzn_website.id
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = aws_cloudfront_origin_access_identity.portfolio_oai.iam_arn
        },
        "Action" = "s3:GetObject",
        "Resource" = "${aws_s3_bucket.cloud_ctzn_website.arn}/*"
      },
    ],
  })
}

# -----------------------------------------------------------------------------
# CLOUDFRONT DISTRIBUTION
# -----------------------------------------------------------------------------

# This is the main CloudFront resource that acts as the CDN for your website.
resource "aws_cloudfront_distribution" "s3_distribution" {
  # The 'origin' block specifies where CloudFront gets its content from.
  origin {
    # We reference the S3 bucket's regional domain name.
    domain_name = aws_s3_bucket.cloud_ctzn_website.bucket_regional_domain_name
    # A unique ID for this origin, which we'll reference later.
    origin_id   = "S3-CloudCtzn-Origin"

    # This links the S3 bucket to the OAI for secure access.
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.portfolio_oai.cloudfront_access_identity_path
    }
  }

  # These are top-level settings for the entire distribution.
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for the CloudCtzn portfolio website"
  # This tells CloudFront to serve 'index.html' when a user visits the root URL.
  default_root_object = "index.html"

  # The 'default_cache_behavior' block defines the caching rules.
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-CloudCtzn-Origin"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]
    

    cookies { 
	forward = "none"
    }
  }

    # CRITICAL FOR SECURITY: This redirects all HTTP traffic to HTTPS.
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # This block configures any geographic restrictions. "none" allows global access.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # This block enables HTTPS using a free certificate provided by CloudFront.
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "portfolio-website-cdn"
    Environment = "production"
  }
}


