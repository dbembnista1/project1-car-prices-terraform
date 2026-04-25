# 🚗 Car Prices Cloud Tracker & Analyzer

An automated, event-driven cloud architecture built on AWS to track, store, and analyze car prices over time. The entire infrastructure is managed as Code (IaC) using **Terraform** and features automated CI/CD pipelines via **GitHub Actions**.

## 🏗️ Architecture Overview

The system is divided into three main logical components:

1. **Data Collection (Event-Driven)**: An AWS EventBridge cron job triggers a Python Lambda function daily. It scrapes real-time car prices from external sources and stores the calculated averages in an Amazon DynamoDB table.
2. **Notification Pipeline (Pipes & Filters)**: Using Lambda Destinations, successful data collection events are pushed to an SNS Topic, formatted by a dedicated Python Lambda, and sent to subscribers via Email using a second SNS Topic.
3. **Web Server & API**: An EC2 instance running Apache and a Node.js/Express application visualizes the data using `Chart.js`. The API is exposed via Amazon API Gateway and secured using Amazon Cognito (OAuth2/Hosted UI).

*(You can put your architecture diagram image here)*

## ✨ Key Features
* **100% Infrastructure as Code**: Fully modularized Terraform setup with conditional resource creation.
* **Zero-Downtime Deployments**: CI/CD pipelines automatically build, zip, and deploy new Lambda & Express.js code without manual intervention.
* **Secure Authentication**: Public API endpoints protected by AWS Cognito User Pools.
* **Serverless Notifications**: Decoupled email notification system utilizing Lambda Destinations and SNS.
* **Dynamic Configuration**: Features can be toggled on/off simply by editing the `.tfvars` file.

## 🛠️ Tech Stack
* **Cloud Provider**: AWS (EC2, Lambda, DynamoDB, API Gateway, Cognito, SNS, EventBridge, IAM, VPC)
* **Infrastructure as Code**: Terraform
* **CI/CD**: GitHub Actions (OIDC Authentication)
* **Backend**: Python 3.14 (Lambdas, BeautifulSoup, Pandas), Node.js / Express (API & Chart generation)
* **Frontend**: HTML, Chart.js (Data Visualization)

---

## 🚀 Setup & Deployment

### 1. Prerequisites
* [Terraform](https://www.terraform.io/downloads.html) installed locally.
* An AWS Account and configured AWS CLI (`aws configure`).

### 2. Infrastructure Configuration
To customize the deployment, create a `terraform/terraform.tfvars` file based on your preferences:

```hcl
project_name = "car-prices"

# 1. Enable GitHub Actions CI/CD (Requires OIDC setup)
enable_github_secrets = true
github_owner          = "your-github-username"
github_repository     = "your-repo-name"

# 2. Enable Daily Data Collection
enable_data_collector = true
collector_urls        = "[https://url1.com](https://url1.com),[https://url2.com](https://url2.com)"

# 3. Enable Email Notifications (Leave empty to disable)
subscriber_email      = "your.email@example.com"
