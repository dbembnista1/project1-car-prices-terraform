resource "aws_ssm_parameter" "test_connection" {
  name  = "/terraform/test-parameter"
  type  = "String"
  value = "Hello from Terraform Cross-Account!"
}


module "database" {
  source = "./modules/database"

  table_name    = "car_prices"
  csv_file_path = "${path.module}/data/historical_data.csv"

  tags = {
    Project     = "CarPrices"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "compute" {
  source = "./modules/compute"

  project_name       = var.project_name
  instance_type      = "t3.micro"
  tags               = var.common_tags
  vpc_id             = module.network.vpc_id 
  dynamodb_table_arn = module.database.table_arn
}