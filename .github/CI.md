# CI/CD Pipeline

This repository uses GitHub Actions for continuous integration and testing.

## Workflows

### CI Pipeline (`.github/workflows/ci.yml`)

The CI pipeline runs on every pull request.

#### Jobs

1. **Terraform Lint** - Checks Terraform code formatting
   - Runs `terraform fmt -check -recursive`
   - Ensures consistent code style

2. **Terraform Validate** - Validates Terraform modules
   - Validates `maas-configure-networking` module
   - Validates `maas-enlist-machines` module
   - Checks syntax and configuration correctness

3. **Terragrunt Validate** - Validates Terragrunt units
   - Validates `maas-configure-networking` unit
   - Validates `maas-enlist-machines` unit
   - Uses mock MAAS credentials for validation

4. **Terratest Unit Tests** - Runs automated tests
   - Validation tests for both modules
   - Module configuration tests
   - Uses Go test cache for faster runs

5. **TFLint** - Static analysis of Terraform code
   - Checks for best practices
   - Validates variable documentation
   - Detects unused declarations

## Running Locally

### Format Check
```bash
terraform fmt -check -recursive
```

### Validation
```bash
# Terraform modules
cd modules/maas-configure-networking
terraform init -backend=false
terraform validate

# Terragrunt units
cd clouds/prod/maas-configure-networking
terragrunt validate
```

### Terratest
```bash
cd test
go test -v -run Validation -timeout 10m
```

### TFLint
```bash
tflint --init
for module in modules/*/; do
  (cd "$module" && tflint --format compact)
done
```

## CI Status

The CI pipeline must pass before merging pull requests. Check the Actions tab for detailed logs.
