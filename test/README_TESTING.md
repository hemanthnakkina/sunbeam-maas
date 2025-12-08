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
```bash
# Module validation tests only
go test -v -run Validation -timeout 10m

# Module tests (with -short to skip integration)
go test -v -short -run TestMaas.*Module -timeout 10m

# Terragrunt tests (with -short to skip integration)
go test -v -short -run TestTerragrunt -timeout 10m

# Run a specific test
go test -v -run TestMaasConfigureNetworkingModuleValidation
```

## Test Files

- `maas_configure_networking_test.go`: Tests for the maas-configure-networking module
- `maas_enlist_machines_test.go`: Tests for the maas-enlist-machines module
- `terragrunt_units_test.go`: Tests for terragrunt configuration and units

## CI/CD Integration

The GitHub Actions workflow runs tests in stages:

1. **Terraform Lint**: Format checking with `terraform fmt`
2. **Terraform Validate**: Module validation with `terraform validate`
3. **Terragrunt Validate**: Terragrunt configuration validation
4. **Terratest Unit Tests**: Structural validation tests (with `-short` flag)
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

When running in short mode, you should see:
- 6 tests skipped (integration tests)
- 8 tests passed (validation and structural tests)
- Total execution time: ~2-3 seconds

## Troubleshooting

### Tests Fail in CI
- Ensure tests use `-short` flag in CI workflow
- Check that integration tests have `if testing.Short() { t.Skip() }`
- Verify structural tests don't require MAAS credentials

### Integration Tests Fail Locally
- Verify MAAS server is accessible
- Check MAAS_API_URL and MAAS_API_KEY environment variables
- Ensure MAAS server version is compatible
- Check network connectivity to MAAS server

### Module Validation Fails
- Run `terraform fmt` to fix formatting
- Check module syntax with `terraform validate`
- Verify provider version constraints
- Review module variable definitions

## Dependencies

- Go 1.21 or later
- Terraform 1.6.0 or later
- Terragrunt 0.93.0 or later (for integration tests)
- Terratest v0.46.8
- MAAS server (for integration tests only)
