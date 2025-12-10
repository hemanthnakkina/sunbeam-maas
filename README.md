# sunbeam-maas
Terragrunt files to deploy sunbeam using maas provider

# Commands to run:
Populate tfvars in all the necessary units.
Check clouds/prod/.terragrunt-excludes for the excluded units and update as per your need.

cd clouds/prod
TF_VAR_maas_api_url="API URL" TF_VAR_maas_api_key="<API KEY>" terragrunt run --all init
TF_VAR_maas_api_url="API URL" TF_VAR_maas_api_key="<API KEY>" terragrunt run --all apply
