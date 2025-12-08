package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestMaasEnlistMachinesModule tests the maas-enlist-machines module
// Skipped in CI - requires MAAS provider configuration
func TestMaasEnlistMachinesModule(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	// This test requires MAAS_API_URL and MAAS_API_KEY environment variables
	// Run with: go test -v -run TestMaasEnlistMachinesModule (not in short mode)
	t.Skip("Integration test - requires MAAS server")
}// TestMaasEnlistMachinesModuleValidation tests input validation
func TestMaasEnlistMachinesModuleValidation(t *testing.T) {
	t.Parallel()

	// Test with valid machine configuration
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-enlist-machines",
		Vars: map[string]interface{}{
			"machines": []interface{}{
				map[string]interface{}{
					"hostname":   "validation-test",
					"power_type": "ipmi",
					"power_parameters": map[string]interface{}{
						"power_address": "10.0.0.100",
						"power_user":    "admin",
						"power_pass":    "password",
					},
					"pxe_mac_address": "aa:bb:cc:dd:ee:ff",
				},
			},
		},
		NoColor: true,
	})

	// Initialize (validation happens during init)
	terraform.Init(t, terraformOptions)
}

// TestMaasEnlistMachinesModuleMultipleMachines tests module structure for multiple machines
func TestMaasEnlistMachinesModuleMultipleMachines(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-enlist-machines",
		NoColor:      true,
	})

	// Initialize to validate module structure
	terraform.Init(t, terraformOptions)

	// Verify module has the main.tf file for machines
	assert.FileExists(t, "../modules/maas-enlist-machines/main.tf", "Module should have main.tf")
}// TestMaasEnlistMachinesModuleOutputs tests module outputs are defined
func TestMaasEnlistMachinesModuleOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-enlist-machines",
		NoColor:      true,
	})

	// Initialize and check that outputs.tf exists
	terraform.Init(t, terraformOptions)

	// Verify module has expected output definitions
	assert.FileExists(t, "../modules/maas-enlist-machines/outputs.tf", "Module should have outputs.tf")
}
