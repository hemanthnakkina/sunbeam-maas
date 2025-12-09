# Testing Guide

This directory contains the test suite for the Terragrunt infrastructure using [Terratest](https://terratest.gruntwork.io/).

## Test Structure

### Unit Tests (Structural Validation)
These tests verify the structure and configuration files without requiring a MAAS server:

- **File Existence Tests**: Check that all required configuration files exist
- **Configuration Validation Tests**: Verify Terraform modules can be initialized
- **Structure Tests**: Validate terragrunt.hcl and module files are properly structured

### Integration Tests
These tests require a live MAAS server and test actual resource deployment:

- **Module Deployment Tests**: Test complete module deployment lifecycle
- **Terragrunt Unit Tests**: Test terragrunt execution and dependencies
- **Plan Tests**: Validate terraform plan generation

## Running Tests

### Quick Validation (CI Mode)
Run structural tests only, without requiring MAAS:
```bash
cd test
go test -v -short -timeout 10m
```

This is what runs in CI/CD pipelines.

### Full Integration Tests
Run all tests including integration tests that deploy to MAAS:
```bash
cd test

# Set MAAS credentials
export MAAS_API_URL="http://your-maas-server:5240/MAAS"
export MAAS_API_KEY="your-api-key"

# Run all tests (no -short flag)
go test -v -timeout 30m
```

### Run Specific Tests

#### By Test Suite
```bash
# All storage tests
go test -v -run 'TestStorageModule.*' -timeout 10m

# Networking tests
go test -v -run 'Test.*Networking.*' -timeout 10m

# Enlist machines tests
go test -v -run 'Test.*Enlist.*' -timeout 10m

# Configure nodes tests
go test -v -run 'Test.*Nodes.*' -timeout 10m

# Terragrunt tests
go test -v -run 'TestTerragrunt.*' -timeout 10m
```

#### Individual Storage Tests
```bash
# Test empty configuration (no MAAS required)
go test -v -run TestStorageModuleEmptyConfiguration

# Test basic partitioning (requires MAAS - currently skipped)
go test -v -run TestStorageModuleBasicPartitioning

# Test storage profiles (requires MAAS - currently skipped)
go test -v -run TestStorageModuleWithProfile

# Test RAID configuration (requires MAAS - currently skipped)
go test -v -run TestStorageModuleRAIDConfiguration

# Test LVM configuration (requires MAAS - currently skipped)
go test -v -run TestStorageModuleLVMConfiguration
```

#### Run a Specific Test
```bash
go test -v -run TestMaasConfigureNetworkingModuleValidation
```

## Test Files

- `maas_configure_nodes_storage_test.go`: Tests for the maas-configure-nodes-storage module (6 tests)
- `maas_configure_nodes_test.go`: Tests for the maas-configure-nodes module (8 tests)
- `maas_configure_networking_test.go`: Tests for the maas-configure-networking module (3 tests)
- `maas_enlist_machines_test.go`: Tests for the maas-enlist-machines module (3 tests)
- `terragrunt_units_test.go`: Tests for terragrunt configuration and units (5 tests)

See `TESTS_SUMMARY.md` for detailed test descriptions and status.

## Environment Variables for Storage Tests

Storage tests use the test fixture pattern and require MAAS credentials:

```bash
# Set mock credentials for local testing
export TF_VAR_maas_api_url="http://localhost:5240/MAAS"
export TF_VAR_maas_api_key="test:consumer:secret"

# Or set actual MAAS credentials for integration tests
export TF_VAR_maas_api_url="http://your-maas-server:5240/MAAS"
export TF_VAR_maas_api_key="your:consumer:token:secret"
```

**Note**: Most storage tests are currently skipped as they require actual MAAS machine data. Only `TestStorageModuleEmptyConfiguration` runs without a MAAS server.

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: '1.6.0'
      
      - name: Run All Tests
        env:
          TF_VAR_maas_api_url: "http://localhost:5240/MAAS"
          TF_VAR_maas_api_key: "test:consumer:secret"
        run: |
          cd test
          go test -v -timeout 5m
```

### GitLab CI Example

```yaml
test:
  stage: test
  image: golang:1.21
  before_script:
    - apt-get update && apt-get install -y wget unzip
    - wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
    - unzip terraform_1.6.0_linux_amd64.zip -d /usr/local/bin/
  variables:
    TF_VAR_maas_api_url: "http://localhost:5240/MAAS"
    TF_VAR_maas_api_key: "test:consumer:secret"
  script:
    - cd test
    - go test -v -timeout 5m
```

The GitHub Actions workflow runs tests in stages:

1. **Terraform Lint**: Format checking with `terraform fmt`
2. **Terraform Validate**: Module validation with `terraform validate`
3. **Terragrunt Validate**: Terragrunt configuration validation
4. **Terratest Unit Tests**: All passing tests (20 tests pass, 5 skip)
5. **TFLint**: Static analysis with tflint

All tests run in parallel where possible to minimize CI time.

## Test Strategy

### Why Two Test Modes?

**Short Mode (`-short` flag)**:
- Runs in CI/CD without MAAS server
- Fast execution (~2-3 seconds)
- Validates structure, syntax, and configuration
- Catches common errors before deployment

**Integration Mode (no `-short` flag)**:
- Requires live MAAS server
- Slower execution (minutes)
- Tests actual resource creation and management
- Validates end-to-end functionality

This approach ensures code quality checks happen on every commit while allowing full integration testing when MAAS is available.

## Writing New Tests

### Adding Structural Tests
```go
func TestNewFeatureStructure(t *testing.T) {
    t.Parallel()
    
    // Check files exist
    assert.FileExists(t, "../path/to/config.hcl")
    
    // Validate module can initialize
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/new-module",
    })
    terraform.Init(t, terraformOptions)
}
```

### Adding Integration Tests
```go
func TestNewFeatureIntegration(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping integration test in short mode")
    }
    t.Parallel()
    
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/new-module",
        // Add MAAS provider config
    })
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Validate outputs and resources
}
```

## Test Results Summary

Current status (as of latest run):
- **Total Tests**: 25
- **Passing**: 20 tests
- **Skipped**: 5 tests (storage tests requiring MAAS machine data)
- **Failed**: 0 tests
- **Execution Time**: ~2.5 seconds

See `TESTS_SUMMARY.md` for detailed breakdown of all tests.

## Troubleshooting

### Tests Fail in CI
- Check that required environment variables are set (`TF_VAR_maas_api_url`, `TF_VAR_maas_api_key`)
- Verify storage tests that require MAAS are properly skipped
- Check network connectivity and module paths

### Storage Tests Are Skipped
- This is expected behavior - 5 storage tests require actual MAAS machine data
- Only `TestStorageModuleEmptyConfiguration` runs without MAAS
- To run skipped tests, you need a real MAAS server with machines enrolled

### Environment Variables Not Working
- Use the exact format: `TF_VAR_maas_api_url` and `TF_VAR_maas_api_key`
- For MAAS API key, use format: `consumer:token:secret` (e.g., `test:consumer:secret`)
- Export variables before running tests:
  ```bash
  export TF_VAR_maas_api_url="http://localhost:5240/MAAS"
  export TF_VAR_maas_api_key="test:consumer:secret"
  go test -v
  ```

### Module Validation Fails
- Run `terraform fmt` to fix formatting
- Check module syntax with `terraform validate`
- Verify provider version constraints
- Review module variable definitions

### Tests Taking Too Long
- Use the `-timeout` flag: `go test -v -timeout 5m`
- Reduce parallelism: `go test -v -parallel 2`
- Run specific test suites instead of all tests

## Dependencies

- Go 1.21 or later
- Terraform 1.6.0 or later
- Terragrunt 0.93.0 or later (for integration tests)
- Terratest v0.46.8
- MAAS server (for integration tests only)
