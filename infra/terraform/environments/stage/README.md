# Staging Terraform root

Separate **IPv4 numbering** (`10.10.0.0/16`) from production (`10.0.0.0/16`) so both stacks may live in one Hetzner Cloud project.

```bash
export HCLOUD_TOKEN=***
cd infra/terraform/environments/stage
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform validate && terraform plan
```

Mirror **different remote state backend key** versus `prod/` (never share `terraform.tfstate`).
