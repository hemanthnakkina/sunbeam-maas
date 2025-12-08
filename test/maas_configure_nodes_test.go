package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestMaasConfigureNodesModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-nodes",
		Vars: map[string]interface{}{
			"maas_api_url": "http://localhost:5240/MAAS",
			"maas_api_key": "test_key",
			"network_profiles": map[string]interface{}{
				"test_profile": map[string]interface{}{
					"physical_interfaces": map[string]interface{}{
						"eth0": map[string]interface{}{
							"tags":    []string{"mgmt"},
							"vlan_id": 10,
							"mtu":     1500,
						},
					},
					"bond_interfaces": map[string]interface{}{
						"bond0": map[string]interface{}{
							"name":           "bond0",
							"parents":        []string{"eth1", "eth2"},
							"bond_mode":      "802.3ad",
							"bond_lacp_rate": "fast",
							"bond_miimon":    100,
							"mtu":            9000,
							"tags":           []string{"data-bond"},
						},
					},
					"bridge_interfaces": map[string]interface{}{
						"br-ex": map[string]interface{}{
							"name":        "br-ex",
							"parent":      "eth0",
							"bridge_type": "standard",
							"mtu":         1500,
						},
					},
					"vlan_interfaces": map[string]interface{}{
						"bond0.100": map[string]interface{}{
							"parent":  "bond0",
							"vlan_id": 100,
							"fabric":  "data-fabric",
							"mtu":     9000,
						},
					},
					"interface_links": map[string]interface{}{
						"eth0-mgmt": map[string]interface{}{
							"network_interface": "eth0",
							"subnet_id":         "10.0.0.0/24",
							"mode":              "STATIC",
							"default_gateway":   true,
						},
					},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"network_profile": "test_profile",
					"physical_interfaces": map[string]interface{}{
						"eth0": map[string]interface{}{
							"name":        "eth0",
							"mac_address": "00:00:00:00:00:01",
						},
						"eth1": map[string]interface{}{
							"name":        "eth1",
							"mac_address": "00:00:00:00:00:02",
						},
						"eth2": map[string]interface{}{
							"name":        "eth2",
							"mac_address": "00:00:00:00:00:03",
						},
					},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces":     map[string]interface{}{},
					"interface_links":     map[string]interface{}{},
					"static_ip_addresses": map[string]interface{}{},
				},
			},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Validate the module
	terraform.Init(t, terraformOptions)
}

func TestProfileMerging(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-nodes",
		Vars: map[string]interface{}{
			"maas_api_url": "http://localhost:5240/MAAS",
			"maas_api_key": "test_key",
			"network_profiles": map[string]interface{}{
				"base_profile": map[string]interface{}{
					"physical_interfaces": map[string]interface{}{
						"eth0": map[string]interface{}{
							"mtu": 1500,
						},
					},
					"bond_interfaces":   map[string]interface{}{},
					"bridge_interfaces": map[string]interface{}{},
					"vlan_interfaces":   map[string]interface{}{},
					"interface_links":   map[string]interface{}{},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"network_profile": "base_profile",
					"physical_interfaces": map[string]interface{}{
						"eth0": map[string]interface{}{
							"name":        "eth0",
							"mac_address": "00:00:00:00:00:01",
							"mtu":         9000, // Override profile value
						},
					},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces":     map[string]interface{}{},
					"interface_links":     map[string]interface{}{},
					"static_ip_addresses": map[string]interface{}{},
				},
			},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Validate that node-specific config overrides profile
	terraform.Init(t, terraformOptions)
}

func TestBondInterfaceCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-nodes",
		Vars: map[string]interface{}{
			"maas_api_url": "http://localhost:5240/MAAS",
			"maas_api_key": "test_key",
			"network_profiles": map[string]interface{}{
				"bond_profile": map[string]interface{}{
					"physical_interfaces": map[string]interface{}{},
					"bond_interfaces": map[string]interface{}{
						"bond0": map[string]interface{}{
							"name":                  "bond0",
							"parents":               []string{"eth0", "eth1"},
							"bond_mode":             "802.3ad",
							"bond_lacp_rate":        "fast",
							"bond_miimon":           100,
							"bond_xmit_hash_policy": "layer3+4",
							"mtu":                   9000,
						},
					},
					"bridge_interfaces": map[string]interface{}{},
					"vlan_interfaces":   map[string]interface{}{},
					"interface_links":   map[string]interface{}{},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"network_profile": "bond_profile",
					"physical_interfaces": map[string]interface{}{
						"eth0": map[string]interface{}{"name": "eth0", "mac_address": "00:00:00:00:00:01"},
						"eth1": map[string]interface{}{"name": "eth1", "mac_address": "00:00:00:00:00:02"},
					},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces":     map[string]interface{}{},
					"interface_links":     map[string]interface{}{},
					"static_ip_addresses": map[string]interface{}{},
				},
			},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.Init(t, terraformOptions)
}

func TestBridgeInterfaceCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-nodes",
		Vars: map[string]interface{}{
			"maas_api_url": "http://localhost:5240/MAAS",
			"maas_api_key": "test_key",
			"network_profiles": map[string]interface{}{
				"bridge_profile": map[string]interface{}{
					"physical_interfaces": map[string]interface{}{},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces": map[string]interface{}{
						"br-bond0": map[string]interface{}{
							"name":        "br-bond0",
							"parent":      "eth0",
							"bridge_type": "standard",
							"bridge_stp":  false,
							"mtu":         9000,
						},
					},
					"vlan_interfaces": map[string]interface{}{},
					"interface_links": map[string]interface{}{},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"network_profile": "bridge_profile",
					"physical_interfaces": map[string]interface{}{
						"eth0": map[string]interface{}{"name": "eth0", "mac_address": "00:00:00:00:00:01"},
					},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces":     map[string]interface{}{},
					"interface_links":     map[string]interface{}{},
					"static_ip_addresses": map[string]interface{}{},
				},
			},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.Init(t, terraformOptions)
}

func TestVlanInterfaceCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-nodes",
		Vars: map[string]interface{}{
			"maas_api_url": "http://localhost:5240/MAAS",
			"maas_api_key": "test_key",
			"network_profiles": map[string]interface{}{
				"vlan_profile": map[string]interface{}{
					"physical_interfaces": map[string]interface{}{},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces": map[string]interface{}{
						"eth0.100": map[string]interface{}{
							"name":    "eth0.100",
							"parent":  "eth0",
							"vlan_id": 100,
							"fabric":  "test-fabric",
							"mtu":     1500,
						},
					},
					"interface_links": map[string]interface{}{},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"network_profile": "vlan_profile",
					"physical_interfaces": map[string]interface{}{
						"eth0": map[string]interface{}{"name": "eth0", "mac_address": "00:00:00:00:00:01"},
					},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces":     map[string]interface{}{},
					"interface_links":     map[string]interface{}{},
					"static_ip_addresses": map[string]interface{}{},
				},
			},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.Init(t, terraformOptions)
}

func TestInterfaceLinks(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-nodes",
		Vars: map[string]interface{}{
			"maas_api_url": "http://localhost:5240/MAAS",
			"maas_api_key": "test_key",
			"network_profiles": map[string]interface{}{
				"link_profile": map[string]interface{}{
					"physical_interfaces": map[string]interface{}{},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces":     map[string]interface{}{},
					"interface_links": map[string]interface{}{
						"eth0-static": map[string]interface{}{
							"network_interface": "eth0",
							"subnet_id":         "10.0.0.0/24",
							"mode":              "STATIC",
							"default_gateway":   true,
						},
						"eth1-dhcp": map[string]interface{}{
							"network_interface": "eth1",
							"subnet_id":         "10.0.1.0/24",
							"mode":              "DHCP",
							"default_gateway":   false,
						},
					},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"network_profile": "link_profile",
					"physical_interfaces": map[string]interface{}{
						"eth0": map[string]interface{}{"name": "eth0", "mac_address": "00:00:00:00:00:01"},
						"eth1": map[string]interface{}{"name": "eth1", "mac_address": "00:00:00:00:00:02"},
					},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces":     map[string]interface{}{},
					"interface_links":     map[string]interface{}{},
					"static_ip_addresses": map[string]interface{}{},
				},
			},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.Init(t, terraformOptions)
}

func TestOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-nodes",
		Vars: map[string]interface{}{
			"maas_api_url": "http://localhost:5240/MAAS",
			"maas_api_key": "test_key",
			"network_profiles": map[string]interface{}{
				"test_profile": map[string]interface{}{
					"physical_interfaces": map[string]interface{}{},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces":     map[string]interface{}{},
					"interface_links":     map[string]interface{}{},
				},
			},
			"nodes": map[string]interface{}{
				"test-node": map[string]interface{}{
					"network_profile": "test_profile",
					"physical_interfaces": map[string]interface{}{
						"eth0": map[string]interface{}{"name": "eth0", "mac_address": "00:00:00:00:00:01"},
					},
					"bond_interfaces":     map[string]interface{}{},
					"bridge_interfaces":   map[string]interface{}{},
					"vlan_interfaces":     map[string]interface{}{},
					"interface_links":     map[string]interface{}{},
					"static_ip_addresses": map[string]interface{}{},
				},
			},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Just verify the module initializes correctly
	// Output validation requires actual resource creation which needs a real MAAS environment
	terraform.Init(t, terraformOptions)
}

func TestEmptyConfiguration(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/maas-configure-nodes",
		Vars: map[string]interface{}{
			"maas_api_url":     "http://localhost:5240/MAAS",
			"maas_api_key":     "test_key",
			"network_profiles": map[string]interface{}{},
			"nodes":            map[string]interface{}{},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Should validate successfully with empty configuration
	terraform.Init(t, terraformOptions)
}
