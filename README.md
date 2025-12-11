# sunbeam-maas
Terragrunt files to deploy Sunbeam using the MAAS provider.

## Quick start

1. Populate tfvars in the necessary unit directories (see `clouds/prod/*` for examples).
2. Check `clouds/prod/.terragrunt-excludes` to review excluded units and update as needed.

From the `clouds/prod` directory run:

```bash
TF_VAR_maas_api_url="API URL" TF_VAR_maas_api_key="<API KEY>" terragrunt run --all init
TF_VAR_maas_api_url="API URL" TF_VAR_maas_api_key="<API KEY>" terragrunt run --all apply
