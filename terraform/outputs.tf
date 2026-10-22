output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.site.id
}

output "website_url" {
  description = "Public URL of the Space Quiz"
  value       = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}
