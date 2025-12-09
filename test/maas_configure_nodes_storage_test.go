package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestStorageModuleBasicPartitioning tests basic block device partitioning without RAID or LVM
func TestStorageModuleBasicPartitioning(t *testing.T) {
	t.Skip("Requires a running MAAS server - run with MAAS_TEST_SERVER environment variable set")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/storage",
		Vars: map[string]interface{}{
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"hostname": "test-node",
					"devices": map[string]interface{}{
						"sda": map[string]interface{}{
							"name":           "sda",
							"serial":         "TEST123",
							"model":          "TestDrive",
							"size_gigabytes": 100,
						},
					},
					"block_devices": map[string]interface{}{
						"sda": map[string]interface{}{
							"name":           "sda",
							"serial":         "TEST123",
							"model":          "TestDrive",
							"size_gigabytes": 100,
							"partitions": []map[string]interface{}{
								{
									"size_gigabytes": 1,
									"fs_type":        "fat32",
									"label":          "efi",
									"mount_point":    "/boot/efi",
								},
								{
									"size_gigabytes": 99,
									"fs_type":        "ext4",
									"mount_point":    "/",
								},
							},
						},
					},
				},
			},
		},
		NoColor: true,
	})

	// Validate the plan
	terraform.Init(t, terraformOptions)
	terraform.Plan(t, terraformOptions)
}

// TestStorageModuleWithProfile tests storage configuration using profiles
func TestStorageModuleWithProfile(t *testing.T) {
	t.Skip("Requires a running MAAS server - run with MAAS_TEST_SERVER environment variable set")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/storage",
		Vars: map[string]interface{}{
			"storage_profiles": map[string]interface{}{
				"hyperconverged": map[string]interface{}{
					"partitions": map[string]interface{}{
						"nvme0n1": []map[string]interface{}{
							{
								"size_gigabytes": 1,
								"fs_type":        "fat32",
								"label":          "efi",
								"mount_point":    "/boot/efi",
							},
							{
								"size_gigabytes": 500,
							},
						},
					},
					"volume_groups": map[string]interface{}{
						"vg0": map[string]interface{}{
							"name":       "vg0",
							"partitions": []string{"nvme0n1.1"},
						},
					},
					"logical_volumes": map[string]interface{}{
						"root": map[string]interface{}{
							"name":           "root",
							"volume_group":   "vg0",
							"size_gigabytes": 67,
							"fs_type":        "ext4",
							"mount_point":    "/",
						},
					},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"hostname":        "test-node",
					"storage_profile": "hyperconverged",
					"devices": map[string]interface{}{
						"nvme0n1": map[string]interface{}{
							"name":           "nvme0n1",
							"serial":         "TEST123",
							"model":          "TestNVMe",
							"size_gigabytes": 1000,
						},
					},
				},
			},
		},
		NoColor: true,
	})

	// Validate the plan
	terraform.Init(t, terraformOptions)
	terraform.Plan(t, terraformOptions)
}

// TestStorageModuleRAIDConfiguration tests RAID array creation
func TestStorageModuleRAIDConfiguration(t *testing.T) {
	t.Skip("Requires a running MAAS server - run with MAAS_TEST_SERVER environment variable set")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/storage",
		Vars: map[string]interface{}{
			"storage_profiles": map[string]interface{}{
				"raid-profile": map[string]interface{}{
					"partitions": map[string]interface{}{
						"sda": []map[string]interface{}{
							{
								"size_gigabytes": 100,
								"tags":           []string{"raid:md0"},
							},
						},
						"sdb": []map[string]interface{}{
							{
								"size_gigabytes": 100,
								"tags":           []string{"raid:md0"},
							},
						},
					},
					"raids": map[string]interface{}{
						"md0": map[string]interface{}{
							"name":       "md0",
							"level":      1,
							"partitions": []string{"sda.0", "sdb.0"},
						},
					},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"hostname":        "test-node",
					"storage_profile": "raid-profile",
					"devices": map[string]interface{}{
						"sda": map[string]interface{}{
							"name":           "sda",
							"serial":         "TEST123",
							"size_gigabytes": 100,
						},
						"sdb": map[string]interface{}{
							"name":           "sdb",
							"serial":         "TEST456",
							"size_gigabytes": 100,
						},
					},
				},
			},
		},
		NoColor: true,
	})

	// Validate the plan
	terraform.Init(t, terraformOptions)
	terraform.Plan(t, terraformOptions)
}

// TestStorageModuleLVMConfiguration tests LVM setup with volume groups and logical volumes
func TestStorageModuleLVMConfiguration(t *testing.T) {
	t.Skip("Requires a running MAAS server - run with MAAS_TEST_SERVER environment variable set")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/storage",
		Vars: map[string]interface{}{
			"storage_profiles": map[string]interface{}{
				"lvm-profile": map[string]interface{}{
					"partitions": map[string]interface{}{
						"sda": []map[string]interface{}{
							{
								"size_gigabytes": 1,
								"fs_type":        "fat32",
								"label":          "efi",
								"mount_point":    "/boot/efi",
							},
							{
								"size_gigabytes": 499,
								"tags":           []string{"vg:vg0"},
							},
						},
					},
					"volume_groups": map[string]interface{}{
						"vg0": map[string]interface{}{
							"name":       "vg0",
							"partitions": []string{"sda.1"},
						},
					},
					"logical_volumes": map[string]interface{}{
						"root": map[string]interface{}{
							"name":           "root",
							"volume_group":   "vg0",
							"size_gigabytes": 67,
							"fs_type":        "ext4",
							"mount_point":    "/",
						},
						"home": map[string]interface{}{
							"name":           "home",
							"volume_group":   "vg0",
							"size_gigabytes": 100,
							"fs_type":        "ext4",
							"mount_point":    "/home",
						},
						"var": map[string]interface{}{
							"name":           "var",
							"volume_group":   "vg0",
							"size_gigabytes": 300,
							"fs_type":        "ext4",
							"mount_point":    "/var",
						},
					},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"hostname":        "test-node",
					"storage_profile": "lvm-profile",
					"devices": map[string]interface{}{
						"sda": map[string]interface{}{
							"name":           "sda",
							"serial":         "TEST123",
							"size_gigabytes": 500,
						},
					},
				},
			},
		},
		NoColor: true,
	})

	// Validate the plan
	terraform.Init(t, terraformOptions)
	terraform.Plan(t, terraformOptions)
}

// TestStorageModuleEmptyConfiguration tests handling of empty/minimal configuration
func TestStorageModuleEmptyConfiguration(t *testing.T) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/storage",
		Vars: map[string]interface{}{
			"nodes": map[string]interface{}{},
		},
		NoColor: true,
	})

	// Validate that empty configuration doesn't error
	terraform.Init(t, terraformOptions)
	terraform.Plan(t, terraformOptions)
}

// TestStorageModuleOutputs tests that module outputs are correctly generated
func TestStorageModuleOutputs(t *testing.T) {
	t.Skip("Requires a running MAAS server - run with MAAS_TEST_SERVER environment variable set")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/storage",
		Vars: map[string]interface{}{
			"storage_profiles": map[string]interface{}{
				"test-profile": map[string]interface{}{
					"partitions": map[string]interface{}{
						"sda": []map[string]interface{}{
							{
								"size_gigabytes": 100,
							},
						},
					},
					"volume_groups": map[string]interface{}{
						"vg0": map[string]interface{}{
							"name":       "vg0",
							"partitions": []string{"sda.0"},
						},
					},
					"logical_volumes": map[string]interface{}{
						"root": map[string]interface{}{
							"name":           "root",
							"volume_group":   "vg0",
							"size_gigabytes": 50,
							"fs_type":        "ext4",
							"mount_point":    "/",
						},
					},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"hostname":        "test-node",
					"storage_profile": "test-profile",
					"devices": map[string]interface{}{
						"sda": map[string]interface{}{
							"name":           "sda",
							"serial":         "TEST123",
							"size_gigabytes": 100,
						},
					},
				},
			},
		},
		NoColor: true,
	})

	// Validate the plan and check outputs
	terraform.Init(t, terraformOptions)
	planOutput := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// Check that outputs are defined
	assert.NotNil(t, planOutput, "Plan output should not be nil")
}
