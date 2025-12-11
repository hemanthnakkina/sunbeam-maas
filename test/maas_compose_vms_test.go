package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// TestMaasComposeVmsModuleBasic tests basic module initialization
func TestMaasComposeVmsModuleBasic(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-compose-vms",
		Lock:         false,
	})

	terraform.Init(t, terraformOptions)
}

// TestMaasComposeVmsModuleInitialization tests module can be initialized
func TestMaasComposeVmsModuleInitialization(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-compose-vms",
		Lock:         false,
	})

	terraform.Init(t, terraformOptions)
}

// TestMaasComposeVmsModuleProvidersConfigured tests providers are available
func TestMaasComposeVmsModuleProvidersConfigured(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-compose-vms",
		Lock:         false,
	})

	terraform.Init(t, terraformOptions)
}
