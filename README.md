# terraform-te

## Choices

## Pitfalls

## Usage
```bash
./install-fed-dependencies.sh
ENV=prod TIER=dr AWS_PROFILE=default make apply
inspec exec install_service_nexus.rb -t ssh://fedora@35.171.84.107 -i ~/.ssh/prod_dr_infra_key --sudo
```
