#!/bin/bash
set -e
terraform fmt -check
terraform init
terraform validate
echo "Validation passed!"
