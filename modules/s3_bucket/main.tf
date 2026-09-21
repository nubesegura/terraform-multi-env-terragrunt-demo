module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0"

  bucket = var.bucket_name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terragrunt"
    Project     = "Base-Infrastructure"
  }

  lifecycle_rule = [
    {
      id     = "lifecycle-rule-${var.environment}"
      status = "Enabled"

      expiration = var.lifecycle_expiration_days > 0 ? {
        days = var.lifecycle_expiration_days
      } : null

      transition = var.lifecycle_transition_days > 0 ? [
        {
          days          = var.lifecycle_transition_days
          storage_class = var.lifecycle_storage_class
        }
      ] : []
    }
  ]
}
