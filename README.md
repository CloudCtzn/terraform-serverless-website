Serverless Portfolio Website on AWS
Project Overview
This project provisions a secure, highly-available, and cost-effective static portfolio website using a modern serverless architecture on AWS. The site was re-architected from a traditional EC2-based setup to a fully managed, pay-per-use model, demonstrating a focus on cost optimization and operational efficiency.

The infrastructure for this project is defined entirely with Terraform, making it easily repeatable and version-controlled.

Architecture
The website is built on a best-practice, serverless architecture. Static files are stored in a private S3 bucket and are served globally via CloudFront.

Amazon S3: The website's static files (HTML, CSS, JS) are hosted in a private S3 bucket, ensuring high durability and availability.

Amazon CloudFront: Acts as a Content Delivery Network (CDN) to serve the content with low latency. It provides a secure HTTPS endpoint with a free SSL certificate and a built-in layer of DDoS protection.

Terraform: Defines and deploys the entire infrastructure as code, from the S3 bucket and CloudFront distribution to the necessary access policies.

Prerequisites
To deploy this infrastructure, you will need:

An AWS account.

The AWS CLI configured on your machine.

Terraform installed locally.

A registered domain name (managed in Route 53 or another registrar).

Deployment
Follow these steps to deploy the infrastructure.

Clone the repository:

Bash

git clone https://github.com/YourUsername/your-repo-name.git
cd your-repo-name
Initialize Terraform:

Bash

terraform init
Create a terraform.tfvars file:
Create a file named terraform.tfvars and add the following line, replacing the value with a globally unique name for your S3 bucket.

Terraform

s3_bucket_name = "your-unique-bucket-name"
Review the Plan:

Bash

terraform plan
This command will show you the resources that Terraform will create.

Apply the Plan:

Bash

terraform apply
Type yes when prompted to confirm the deployment.

Upload Your Website:
Once the deployment is complete, upload your website's static files (index.html, style.css, etc.) directly to the S3 bucket created by Terraform.

Update DNS Records:
After applying the plan, Terraform will output the CloudFront domain name. Create a new A record in your domain's hosted zone and set it as an Alias record pointing to this CloudFront domain.

Cost
This architecture is extremely cost-effective. For a low-traffic personal portfolio website, all costs will likely fall within the AWS Free Tier, making it virtually free to run.

