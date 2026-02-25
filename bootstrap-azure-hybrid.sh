#!/bin/bash

set -e

echo "======================================"
echo "Bootstrapping Azure Hybrid Hub"
echo "======================================"

cd infra/azure-hub

echo "Initializing Terraform..."
terraform init -input=false

echo "Validating Terraform..."
terraform validate

echo "Planning..."
terraform plan -out=tfplan

echo "Applying..."
terraform apply -auto-approve tfplan

echo "======================================"
echo "Deployment Complete"
echo "======================================"

terraform output public_ip
