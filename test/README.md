# Terratest Tests for sunbeam-maas

This directory contains automated tests for the Terragrunt modules and units using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

- Go 1.21 or later
- Terraform
- Terragrunt
- MAAS server (for integration tests)

## Setup

Initialize Go modules:

```bash
cd test
go mod download
```

## Running Tests

### Run all tests
```bash
cd test
go test -v -timeout 30m
```

### Run specific test
```bash
cd test
go test -v -timeout 30m -run TestMaasConfigureNetworkingModule
```

### Run tests in parallel
```bash
cd test
go test -v -timeout 30m -parallel 10
```

## Test Structure

### Module Tests
- `maas_configure_networking_test.go` - Tests for the networking module
  - Input validation
  - Resource planning
  - Output validation
  
- `maas_enlist_machines_test.go` - Tests for the machines module
  - Single and multiple machine configurations

- `maas_configure_nodes_test.go` - Tests for the node configuration module
  - Module validation
  - Profile merging logic
  - Bond interface creation
  - Bridge interface creation
  - VLAN interface creation
  - Interface link configuration (STATIC, DHCP, AUTO)
  - Output validation
  - Empty configuration handling
  - Power type validation
  - Output checks

### Terragrunt Unit Tests
- `terragrunt_units_test.go` - Tests for Terragrunt units
  - Unit validation
  - Plan generation
  - Dependency resolution

## Test Types

### 1. Validation Tests
Test that modules validate correctly with valid inputs:
```bash
go test -v -run TestValidation
```

### 2. Plan Tests
Test that Terraform plans are generated correctly:
```bash
go test -v -run TestPlan
```

### 3. Integration Tests (requires MAAS)
Full apply/destroy cycle tests:
```bash
# Set MAAS credentials
export MAAS_API_URL="http://your-maas-server:5240/MAAS"
export MAAS_API_KEY="your-api-key"

# Run integration tests
go test -v -timeout 30m -run TestIntegration
```

## CI/CD Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run Terratest
  run: |
    cd test
    go test -v -timeout 30m
```

## Notes

- Tests run in parallel by default (use `-parallel` flag to control)
- Use `-timeout` to set maximum test duration
- Mock MAAS credentials are used for validation/plan tests
- Full integration tests require actual MAAS server access
