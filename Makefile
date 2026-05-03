# Convenience targets — requires terraform + ansible on PATH
.PHONY: terraform-init terraform-plan terraform-plan-stage terraform-apply terraform-apply-stage terraform-destroy ansible-harden ansible-site ansible-patch-hotfix ansible-all

ROOT := $(CURDIR)

terraform-init:
	terraform -chdir=$(ROOT)/infra/terraform/environments/prod init -upgrade -input=false

terraform-plan:
	terraform -chdir=$(ROOT)/infra/terraform/environments/prod plan -input=false

terraform-plan-stage:
	terraform -chdir=$(ROOT)/infra/terraform/environments/stage plan -input=false

terraform-apply-stage:
	terraform -chdir=$(ROOT)/infra/terraform/environments/stage apply -input=false

terraform-apply:
	terraform -chdir=$(ROOT)/infra/terraform/environments/prod apply -input=false

terraform-destroy:
	terraform -chdir=$(ROOT)/infra/terraform/environments/prod destroy -input=false

ANSIBLE_INV ?= $(ROOT)/infra/ansible/inventory/example.hosts.yml

ansible-harden:
	ansible-playbook -i $(ANSIBLE_INV) $(ROOT)/infra/ansible/playbooks/hardening.yml

ansible-site:
	ansible-playbook -i $(ANSIBLE_INV) $(ROOT)/infra/ansible/playbooks/site.yml --ask-vault-pass

# Example CVE pin: EXTRA=-e gitlab_ce_apt_pin_version=17.11.8-ce.0 EXTRA+=-e gitlab_runner_apt_pin_version=...
ansible-patch-hotfix:
	ansible-playbook -i $(ANSIBLE_INV) $(ROOT)/infra/ansible/playbooks/patch_critical_stack.yml --ask-vault-pass $(EXTRA)

ansible-all:
	ansible-playbook -i $(ANSIBLE_INV) $(ROOT)/infra/ansible/playbooks/hardening.yml --ask-vault-pass && \
	ansible-playbook -i $(ANSIBLE_INV) $(ROOT)/infra/ansible/playbooks/bastion.yml --ask-vault-pass && \
	ansible-playbook -i $(ANSIBLE_INV) $(ROOT)/infra/ansible/playbooks/gitlab.yml --ask-vault-pass && \
	ansible-playbook -i $(ANSIBLE_INV) $(ROOT)/infra/ansible/playbooks/runners.yml --ask-vault-pass
