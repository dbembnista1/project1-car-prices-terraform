output "lambda_name" {
  description = "The name of the Data Collector Lambda function"
  value       = aws_lambda_function.collector.function_name
}