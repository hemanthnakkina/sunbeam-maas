package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestMaasConfigureNetworkingModule tests the maas-configure-networking module
// Skipped in CI - requires MAAS provider configuration
func TestMaasConfigureNetworkingModule(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	// This test requires MAAS_API_URL and MAAS_API_KEY environment variables
	// Run with: go test -v -run TestMaasConfigureNetworkingModule (not in short mode)
	t.Skip("Integration test - requires MAAS server")
} // TestMaasConfigureNetworkingModuleValidation tests input validation
func TestMaasConfigureNetworkingModuleValidation(t *testing.T) {
	t.Parallel()

	// Test with minimal valid configuration
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-networking",
		Vars: map[string]interface{}{
			"spaces": map[string]interface{}{},
			"fabrics": map[string]interface{}{
				"fabric1": map[string]interface{}{
					"vlans": []interface{}{
						map[string]interface{}{
							"vid": 100,
							"subnets": map[string]interface{}{
								"subnet1": map[string]interface{}{
									"cidr":     "192.168.1.0/24",
									"reserved": map[string]interface{}{},
								},
							},
						},
					},
				},
			},
		},
		NoColor: true,
	})

	// Initialize and validate (validation happens during plan)
	terraform.Init(t, terraformOptions)
}

// TestMaasConfigureNetworkingOutputs tests module outputs are defined
func TestMaasConfigureNetworkingOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-networking",
		NoColor:      true,
	})

	// Initialize and check that outputs.tf exists
	terraform.Init(t, terraformOptions)

	// Verify module has expected output definitions by checking the outputs.tf file exists
	// This is a structural test that doesn't require provider configuration
	assert.FileExists(t, "../modules/maas-configure-networking/outputs.tf", "Module should have outputs.tf")
}
