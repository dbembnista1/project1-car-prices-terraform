module "database" {
  source        = "./modules/database"
  table_name    = "car_prices"
  csv_file_path = "${path.module}/data/historical_data.csv"
  tags          = var.common_tags
}


module "network" {
  source       = "./modules/network"
  project_name = var.project_name
}

#Apache server
module "compute" {
  source             = "./modules/compute"
  project_name       = var.project_name
  instance_type      = "t3.micro"
  tags               = var.common_tags
  
  #network
  vpc_id             = module.network.vpc_id 
  subnet_id          = module.network.public_subnet_id 
  
  #db
  dynamodb_table_arn = module.database.table_arn
}


module "cognito" {
  source        = "./modules/cognito"
  project_name  = var.project_name
  web_server_ip = module.compute.instance_public_ip
}



module "api" {
  source                = "./modules/api"
  project_name          = var.project_name
  dynamodb_table_arn    = module.database.table_arn
  cognito_user_pool_arn = module.cognito.user_pool_arn
}


resource "github_actions_secret" "ec2_host" {
  # If enable_github_secrets = true, create 1. Else 0.
  count           = var.enable_github_secrets ? 1 : 0
  
  repository      = var.github_repository
  secret_name     = "EC2_HOST"
  plaintext_value = module.compute.instance_public_ip
}

resource "github_actions_secret" "ec2_ssh_key" {
  count           = var.enable_github_secrets ? 1 : 0
  
  repository      = var.github_repository
  secret_name     = "EC2_SSH_KEY"
  plaintext_value = module.compute.private_key_pem
}

resource "github_actions_secret" "project_name" {
  count           = var.enable_github_secrets ? 1 : 0
  repository      = var.github_repository
  secret_name     = "PROJECT_NAME"
  plaintext_value = var.project_name
}
