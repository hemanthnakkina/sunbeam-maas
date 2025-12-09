# Test Fixtures

This directory contains test fixtures for Terraform modules. Fixtures are wrapper configurations that include both the module being tested and the necessary provider configuration.

## Why Fixtures?

Fixtures allow us to:
1. Keep modules provider-agnostic (no provider configuration in module code)
2. Test modules with mock/test credentials
3. Maintain clean separation between production code and test infrastructure
4. Easily test different configurations without modifying the module

## Structure

### storage/

Test fixture for the `maas-configure-nodes-storage` module.

**Files:**
- `main.tf` - Module invocation and provider configuration
- `versions.tf` - Terraform and provider version constraints

**Usage:**
The storage tests in `../maas_configure_nodes_storage_test.go` use this fixture:

```go
terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
    TerraformDir: "./fixtures/storage",
    Vars: map[string]interface{}{
        "machines": ...,
    },
})
```

**Provider Configuration:**
The fixture includes mock MAAS provider credentials:
- API URL: `http://localhost:5240/MAAS`
- API Key: `test:consumer:secret`

These can be overridden via environment variables:
```bash
export TF_VAR_maas_api_url="http://your-maas:5240/MAAS"
export TF_VAR_maas_api_key="your:api:key"
```

## Adding New Fixtures

When adding tests for a new module:

1. Create a new directory under `fixtures/`
2. Add `main.tf` with:
   - Variable declarations
   - Provider configuration
   - Module invocation
   - Output pass-through
3. Add `versions.tf` with provider requirements
4. Update tests to point to `./fixtures/<your-module>`

## Best Practices

- ✅ Keep fixtures minimal - only what's needed for testing
- ✅ Use variables for all configurable values
- ✅ Pass through module outputs for test validation
- ✅ Use mock credentials by default
- ✅ Document any special requirements
- ❌ Don't include actual production credentials
- ❌ Don't add business logic to fixtures
- ❌ Don't test multiple modules in one fixture
