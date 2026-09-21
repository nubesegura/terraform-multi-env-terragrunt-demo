variable "bucket_name" {
  description = "Unique name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment (dev, qa, prod)"
  type        = string
}

variable "lifecycle_expiration_days" {
  description = "Days to expire objects (0 to disable)"
  type        = number
  default     = 0
}

variable "lifecycle_transition_days" {
  description = "Days to transition objects to another storage class (0 to disable)"
  type        = number
  default     = 0
}

variable "lifecycle_storage_class" {
  description = "Storage class for the transition (e.g., GLACIER, STANDARD_IA)"
  type        = string
  default     = "GLACIER"
}
