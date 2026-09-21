locals {
  # Cargar variables del entorno desde el archivo env.hcl del directorio donde se ejecuta terragrunt (ej. dev, qa, prod)
  env_vars = read_terragrunt_config("${get_terragrunt_dir()}/env.hcl")

  # Extraer variables para usarlas más fácilmente
  env      = local.env_vars.locals.environment
  account  = get_aws_account_id()
  region   = local.env_vars.locals.aws_region
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # Interpolamos las variables dinámicas
    bucket         = "terraform-state-${local.env}-${local.account}-${local.region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    use_lockfile   = true
  }
}

# Inyectamos variables dinámicas hacia el módulo de Terraform
# bucket_name y environment se construyen dinámicamente usando get_aws_account_id()
# Las variables de lifecycle se toman desde env.hcl (entornos) y pueden sobreescribirse con pipeline.tfvars
inputs = {
  bucket_name               = "my-app-data-${local.env}-${local.account}-${local.region}"
  environment               = local.env
  lifecycle_expiration_days = local.env_vars.locals.lifecycle_expiration_days
  lifecycle_transition_days = local.env_vars.locals.lifecycle_transition_days
}
