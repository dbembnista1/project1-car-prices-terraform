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