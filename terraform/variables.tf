variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "enable_github_secrets" {
  description = "Set to true to automatically configure CICD for web server code (EC2 IP and SSH Key needed) and configure CICD for infra (OICD connection to AWS needed) using GitHub Actions Secrets"
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "Name of the GitHub repository for secrets injection"
  type        = string
  default     = ""
}