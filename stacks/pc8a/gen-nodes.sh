#!/bin/bash

# This generate HCL definition of a single MAAS node given it's system ID:
maas root machine read '<system-id>' | jq -r '
# Extract hostname for the node key
(.hostname) as $hostname |

# Process devices (physical block devices only)
(
  [.physicalblockdevice_set[] |
    "      " + .name + " = {\n" +
    "        name           = \"" + .name + "\"\n" +
    "        size_gigabytes = " + ((.size / 1073741824) | floor | tostring) + "\n" +
    "        block_size     = " + (.block_size | tostring) + "\n" +
    "        is_boot_device = " + (if .name == (.boot_disk.name // "") then "true" else "false" end) + "\n" +
    "        tags = [\n" +
    (if (.tags | length) > 0 then (.tags | map("          \"" + . + "\",") | join("\n")) + "\n" else "" end) +
    "        ]\n" +
    "        model  = \"" + .model + "\"\n" +
    "        serial = \"" + .serial + "\"\n" +
    "      }"
  ] | join("\n")
) as $devices |

# Process physical interfaces only
(
  [.interface_set[] | select(.type == "physical") |
    "      " + .name + " = {\n" +
    "        mac_address = \"" + .mac_address + "\"\n" +
    "      }"
  ] | join("\n")
) as $interfaces |

# Build the final HCL structure
"  " + $hostname + " = {\n" +
"    hostname        = \"" + $hostname + "\"\n" +
"    storage_profile = \"hyperconverged\"\n" +
"    network_profile = \"hyperconverged\"\n\n" +
"    devices = {\n" +
$devices + "\n" +
"    }\n\n" +
"    physical_interfaces = {\n" +
$interfaces + "\n" +
"    }\n" +
"  }"
'
