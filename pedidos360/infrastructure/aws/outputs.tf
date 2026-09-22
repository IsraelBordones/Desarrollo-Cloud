output "api_gateway_dev_url" {
  description = "API Gateway invoke URL (dev stage)"
  value       = aws_apigatewayv2_stage.dev.invoke_url
}

output "api_gateway_qa_url" {
  description = "API Gateway invoke URL (qa stage)"
  value       = aws_apigatewayv2_stage.qa.invoke_url
}

output "api_gateway_endpoint" {
  description = "Base API endpoint"
  value       = aws_apigatewayv2_api.http.api_endpoint
}

#output "cloudfront_url" {
#  description = "CloudFront distribution URL for the Angular frontend"
#  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
#}

#output "frontend_bucket" {
#  description = "S3 bucket name for the Angular build"
#  value       = aws_s3_bucket.frontend.id
#}

output "ec2_public_ips" {
  description = "Public IPs of the microservice EC2 instances"
  value       = { for k, v in aws_instance.service : k => v.public_ip }
}
