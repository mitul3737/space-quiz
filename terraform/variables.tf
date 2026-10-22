variable "region" {
  description = "AWS region for the bucket"
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Prefix for resource names"
  type        = string
  default     = "space-quiz"
}

variable "site_file" {
  description = "Path to the quiz page to upload"
  type        = string
  default     = "../index.html"
}
