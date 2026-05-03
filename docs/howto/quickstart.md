# Quickstart — secure red/blue GitLab platform

## Prerequisites

Operator laptop with SSH keypair, Vault/password manager access, Terraform >= 1.5, Ansible >= 2.16, exported `HCLOUD_TOKEN`.

## 1. Configure Terraform vars

```bash
cd infra/terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars
"${EDITOR:-nano}" terraform.tfvars
```

Narrow **`vpn_ingress_allowlist`** and **`ssh_bootstrap_allowlist`** to office `/32` egress before bootstrap.

```bash
export HCLOUD_TOKEN="$(pass infra/hetzner)"   # pseudocode — never paste token into shell history plaintext
terraform init && terraform validate && terraform plan
terraform apply -input=false                # allocates network + bastion + GitLab VM + runners
terraform output ansible_inventory_snippet >> ../../../../infra/ansible/inventory/generated.hosts
```

Merge generated inventory into Ansible inventory YAML (see [`example.hosts.yml`](../../infra/ansible/inventory/example.hosts.yml)).

## 2. WireGuard bastion skeleton

Bootstrap WireGuard peers using [`bastion_wireguard`](../../infra/ansible/roles/bastion_wireguard). Store server private key in vault:

```bash
cd infra/ansible
cp group_vars/vault.yml.example group_vars/vault.yml
ansible-vault encrypt group_vars/vault.yml
ansible-playbook -i inventory/prod.yml playbooks/bastion.yml --ask-vault-pass
```

## 3. Install GitLab Omnibus & runners

Populate `gitlab_external_url` (must match reachable hostname from runners + engineers over VPN DNS).

```bash
ansible-playbook playbooks/gitlab.yml -i inventory/prod.yml --ask-vault-pass
ansible-playbook playbooks/runners.yml -i inventory/prod.yml --ask-vault-pass
```

Or converge everything in order (long maintenance window):

```bash
ansible-playbook playbooks/site.yml -i inventory/prod.yml --ask-vault-pass
# from repo root: make ansible-site ANSIBLE_INV=infra/ansible/inventory/prod.yml
```

## Destroy / teardown

```bash
cd infra/terraform/environments/prod
terraform destroy -input=false
```

## Next steps

- Apply [`deploy_start_destroy`](deploy_start_destroy.md) checklist.
- Align GitLab SSO + MFA per [`auth_security_setup`](auth_security_setup.md).
