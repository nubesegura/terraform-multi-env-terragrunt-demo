# Variables de ciclo de vida para el entorno dev
# bucket_name y environment son inyectadas dinámicamente por root.hcl via get_aws_account_id()
lifecycle_expiration_days = 7
lifecycle_transition_days = 0
