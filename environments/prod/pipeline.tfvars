# Variables de ciclo de vida para el entorno prod
# bucket_name y environment son inyectadas dinámicamente por root.hcl via get_aws_account_id()
lifecycle_expiration_days = 365
lifecycle_transition_days = 30
lifecycle_storage_class   = "GLACIER"
