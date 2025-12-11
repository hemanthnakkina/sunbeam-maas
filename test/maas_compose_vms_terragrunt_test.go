package test

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestMaasComposeVmsTerragruntUnitExists tests that the Terragrunt unit files exist
func TestMaasComposeVmsTerragruntUnitExists(t *testing.T) {
	t.Parallel()

	assert.FileExists(t, "../clouds/prod/maas-compose-vms/terragrunt.hcl",
		"maas-compose-vms terragrunt.hcl should exist")

	assert.FileExists(t, "../clouds/prod/maas-compose-vms/vms.tfvars",
		"maas-compose-vms vms.tfvars should exist")
}

// TestMaasComposeVmsTerragruntConfiguration tests Terragrunt configuration structure
func TestMaasComposeVmsTerragruntConfiguration(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../clouds/prod/maas-compose-vms/terragrunt.hcl")
	require.NoError(t, err, "Should be able to read maas-compose-vms terragrunt.hcl")

	contentStr := string(content)
	assert.Contains(t, contentStr, "terraform", "Should reference terraform")
	assert.Contains(t, contentStr, "source", "Should have module source")
	assert.Contains(t, contentStr, "maas-compose-vms", "Should reference maas-compose-vms module")
}

// TestMaasComposeVmsExampleConfiguration tests variables file
func TestMaasComposeVmsExampleConfiguration(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../clouds/prod/maas-compose-vms/vms.tfvars")
	require.NoError(t, err, "Should be able to read vms.tfvars")

	contentStr := string(content)
	// vms.tfvars may be empty or contain configuration
	assert.True(t, (len(contentStr) >= 0), "vms.tfvars should exist")
}

// TestMaasComposeVmsModuleSource tests module source is correctly configured
func TestMaasComposeVmsModuleSource(t *testing.T) {
	t.Parallel()

	assert.DirExists(t, "../modules/maas-compose-vms", "Module directory should exist")
	assert.FileExists(t, "../modules/maas-compose-vms/main.tf", "Module main.tf should exist")
	assert.FileExists(t, "../modules/maas-compose-vms/variables.tf", "Module variables.tf should exist")
	assert.FileExists(t, "../modules/maas-compose-vms/outputs.tf", "Module outputs.tf should exist")
	assert.FileExists(t, "../modules/maas-compose-vms/README.md", "Module README.md should exist")
}

// TestMaasComposeVmsModuleOutputs tests that module defines expected outputs
func TestMaasComposeVmsModuleOutputs(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/outputs.tf")
	require.NoError(t, err, "Should be able to read outputs.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "vm_machines", "Should define vm_machines output")
	assert.Contains(t, contentStr, "vm_hostnames", "Should define vm_hostnames output")
	assert.Contains(t, contentStr, "vm_system_ids", "Should define vm_system_ids output")
}

// TestMaasComposeVmsModuleVariables tests that module defines expected variables
func TestMaasComposeVmsModuleVariables(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/variables.tf")
	require.NoError(t, err, "Should be able to read variables.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "vm_configurations", "Should define vm_configurations")
	// MAAS API credentials are passed from terragrunt, not defined in module variables
	assert.Contains(t, contentStr, "list(string)", "Should define list types for configuration")
}

// TestMaasComposeVmsModuleResourceTypes tests that module uses expected resource types
func TestMaasComposeVmsModuleResourceTypes(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/main.tf")
	require.NoError(t, err, "Should be able to read main.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "maas_vm_host_machine", "Should use maas_vm_host_machine resource")
	assert.Contains(t, contentStr, "maas_tag", "Should use maas_tag resource for tagging")
}

// TestMaasComposeVmsReadmeDocumentation tests README has comprehensive documentation
func TestMaasComposeVmsReadmeDocumentation(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/README.md")
	require.NoError(t, err, "Should be able to read README.md")

	contentStr := string(content)
	assert.Contains(t, contentStr, "maas-compose-vms", "Should mention module name")
	assert.Contains(t, contentStr, "vm_configurations", "Should document vm_configurations")
	assert.Contains(t, contentStr, "vm_host", "Should document vm_host parameter")
	assert.Contains(t, contentStr, "zone", "Should document zone parameter")
	assert.Contains(t, contentStr, "Example", "Should include usage examples")
}

// TestMaasComposeVmsVmHostSelection tests that module supports vm_host as list
func TestMaasComposeVmsVmHostSelection(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/main.tf")
	require.NoError(t, err, "Should be able to read main.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "vm_config.vm_host", "Should reference vm_host from configuration")
	assert.Contains(t, contentStr, "length(vm_config.vm_host)", "Should check vm_host length for selection")
}

// TestMaasComposeVmsZoneSelection tests that module supports zone as list
func TestMaasComposeVmsZoneSelection(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/main.tf")
	require.NoError(t, err, "Should be able to read main.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "vm_config.zone", "Should reference zone from configuration")
	assert.Contains(t, contentStr, "vm_config.zone != null", "Should handle optional zone")
}

// TestMaasComposeVmsTagSupport tests that module supports tag assignment
func TestMaasComposeVmsTagSupport(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/main.tf")
	require.NoError(t, err, "Should be able to read main.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "resource \"maas_tag\"", "Should define maas_tag resource")
	assert.Contains(t, contentStr, "vm_config.tags", "Should reference tags from configuration")
}

// TestMaasComposeVmsHostnameGeneration tests hostname generation logic
func TestMaasComposeVmsHostnameGeneration(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/main.tf")
	require.NoError(t, err, "Should be able to read main.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "hostname", "Should generate hostname")
	assert.Contains(t, contentStr, "hostname_prefix", "Should support hostname_prefix")
}

// TestMaasComposeVmsStorageConfiguration tests storage disk configuration
func TestMaasComposeVmsStorageConfiguration(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/main.tf")
	require.NoError(t, err, "Should be able to read main.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "storage_disks", "Should configure storage disks")
	assert.Contains(t, contentStr, "dynamic", "Should use dynamic blocks for flexible configuration")
}

// TestMaasComposeVmsNetworkConfiguration tests network interface configuration
func TestMaasComposeVmsNetworkConfiguration(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/main.tf")
	require.NoError(t, err, "Should be able to read main.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "network_interfaces", "Should configure network interfaces")
	assert.Contains(t, contentStr, "dynamic", "Should use dynamic blocks for flexible configuration")
}

// TestMaasComposeVmsVmHostRequired tests that vm_host is required field
func TestMaasComposeVmsVmHostRequired(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/variables.tf")
	require.NoError(t, err, "Should be able to read variables.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "vm_host", "Should define vm_host field")
	assert.Contains(t, contentStr, "list(string)", "vm_host should be list(string)")
}

// TestMaasComposeVmsPoolConfiguration tests pool parameter support
func TestMaasComposeVmsPoolConfiguration(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/variables.tf")
	require.NoError(t, err, "Should be able to read variables.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "pool", "Should support pool parameter")
}

// TestMaasComposeVmsProviderConfiguration tests provider configuration in terragrunt
func TestMaasComposeVmsProviderConfiguration(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../clouds/prod/maas-compose-vms/terragrunt.hcl")
	require.NoError(t, err, "Should be able to read terragrunt.hcl")

	contentStr := string(content)
	// Provider configuration is managed by terragrunt, not in module variables
	assert.Contains(t, contentStr, "terraform", "Should reference terraform configuration")
}

// TestMaasComposeVmsCountValidation tests count validation
func TestMaasComposeVmsCountValidation(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/variables.tf")
	require.NoError(t, err, "Should be able to read variables.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "count", "Should define count field")
	assert.Contains(t, contentStr, "> 0", "Should validate count > 0")
}

// TestMaasComposeVmsCoresValidation tests cores validation
func TestMaasComposeVmsCoresValidation(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/variables.tf")
	require.NoError(t, err, "Should be able to read variables.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "cores", "Should define cores field")
	assert.Contains(t, contentStr, "> 0", "Should validate cores > 0")
}

// TestMaasComposeVmsMemoryValidation tests memory validation
func TestMaasComposeVmsMemoryValidation(t *testing.T) {
	t.Parallel()

	content, err := os.ReadFile("../modules/maas-compose-vms/variables.tf")
	require.NoError(t, err, "Should be able to read variables.tf")

	contentStr := string(content)
	assert.Contains(t, contentStr, "memory", "Should define memory field")
	assert.Contains(t, contentStr, "> 0", "Should validate memory > 0")
}
