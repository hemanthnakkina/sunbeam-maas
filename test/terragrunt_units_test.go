package test

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

// TestMaasConfigureNetworkingTerragruntUnit tests the maas-configure-networking Terragrunt unit
// Skipped in CI - requires full Terragrunt execution
func TestMaasConfigureNetworkingTerragruntUnit(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Terragrunt integration test in short mode")
	}
	t.Parallel()

	// This test requires full Terragrunt execution with MAAS
	t.Skip("Integration test - requires Terragrunt and MAAS server")
}

// TestMaasConfigureNetworkingTerragruntPlan tests plan generation for the unit
// Skipped in CI - requires full Terragrunt execution
func TestMaasConfigureNetworkingTerragruntPlan(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Terragrunt integration test in short mode")
	}
	t.Parallel()

	// This test requires full Terragrunt execution with MAAS
	t.Skip("Integration test - requires Terragrunt and MAAS server")
}

// TestMaasEnlistMachinesTerragruntUnit tests the maas-enlist-machines Terragrunt unit
// Skipped in CI - requires full Terragrunt execution
func TestMaasEnlistMachinesTerragruntUnit(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Terragrunt integration test in short mode")
	}
	t.Parallel()

	// This test requires full Terragrunt execution with MAAS
	t.Skip("Integration test - requires Terragrunt and MAAS server")
}

// TestTerragruntDependencies tests that unit dependencies are correctly configured
// Skipped in CI - requires full Terragrunt execution
func TestTerragruntDependencies(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping Terragrunt integration test in short mode")
	}
	t.Parallel()

	// This test requires full Terragrunt execution with MAAS
	t.Skip("Integration test - requires Terragrunt and MAAS server")
}

// TestTerragruntFilesExist tests that Terragrunt configuration files exist
func TestTerragruntFilesExist(t *testing.T) {
	t.Parallel()

	// Check root terragrunt.hcl
	assert.FileExists(t, "../terragrunt.hcl", "Root terragrunt.hcl should exist")
	assert.FileExists(t, "../common.hcl", "Common terragrunt configuration should exist")

	// Check prod environment
	assert.FileExists(t, "../clouds/prod/terragrunt.hcl", "Prod environment terragrunt.hcl should exist")

	// Check maas-configure-networking unit
	assert.FileExists(t, "../clouds/prod/maas-configure-networking/terragrunt.hcl",
		"maas-configure-networking terragrunt.hcl should exist")
	// Check for example file since actual tfvars may not be committed
	assert.FileExists(t, "../clouds/prod/maas-configure-networking/networking.tfvars.example",
		"maas-configure-networking example variables file should exist")

	// Check maas-enlist-machines unit
	assert.FileExists(t, "../clouds/prod/maas-enlist-machines/terragrunt.hcl",
		"maas-enlist-machines terragrunt.hcl should exist")
	// Check for example file (machines.tfvars may exist but .example should always be there)
	assert.FileExists(t, "../clouds/prod/maas-enlist-machines/machines.tfvars.example",
		"maas-enlist-machines example variables file should exist")
}

// TestTerragruntConfigStructure tests basic structure of terragrunt configs
func TestTerragruntConfigStructure(t *testing.T) {
	t.Parallel()

	// Read and check root terragrunt.hcl contains expected content
	content, err := os.ReadFile("../terragrunt.hcl")
	assert.NoError(t, err, "Should be able to read root terragrunt.hcl")
	assert.Contains(t, string(content), "terraform", "Root config should reference terraform")

	// Read and check common.hcl
	commonContent, err := os.ReadFile("../common.hcl")
	assert.NoError(t, err, "Should be able to read common.hcl")
	assert.Contains(t, string(commonContent), "sunbeam-maas", "Common config should contain project name")
}
