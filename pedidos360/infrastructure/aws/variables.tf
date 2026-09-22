variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name / resource prefix"
  type        = string
  default     = "pedidos360"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance type (AWS Academy allows t2.micro / t3.micro)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH (optional)"
  type        = string
  default     = ""
}

variable "ec2_instance_profile" {
  description = "IAM instance profile. In AWS Academy this is usually 'LabInstanceProfile'"
  type        = string
  default     = "LabInstanceProfile"
}

variable "azure_tenant_id" {
  description = "Azure AD tenant ID (for the JWT authorizer issuer)"
  type        = string
}

variable "azure_api_audience" {
  description = "Expected JWT audience, e.g. api://pedidos360-api"
  type        = string
  default     = "api://pedidos360-api"
}

variable "azure_client_id" {
  description = "Azure AD application (client) ID (also accepted as audience)"
  type        = string
}

variable "cors_allowed_origins" {
  description = "Allowed CORS origins for the API Gateway"
  type        = list(string)
  default     = ["*"]
}

variable "artifacts_base_url" {
  description = "HTTP base URL where the built service jars are published"
  type        = string
  default     = "https://artefactos-pedidos360.s3.us-east-1.amazonaws.com"
}
