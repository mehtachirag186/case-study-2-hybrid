#!/bin/bash

set -e

echo "======================================"
echo "Destroying Azure Hybrid Hub"
echo "======================================"

cd infra/azure-hub

terraform destroy -auto-approve

echo "======================================"
echo "All resources destroyed."
echo "======================================"
