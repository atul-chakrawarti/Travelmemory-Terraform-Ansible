# TravelMemory on AWS with Terraform and Ansible

Deploys the TravelMemory MERN app (React + Express + MongoDB) on AWS ap-south-1.

- `terraform/`: VPC, public and private subnets, IGW, NAT, route tables, security groups, IAM role, 2 EC2 servers, web IP output
- `ansible/`: roles `common`, `hardening`, `mongodb`, `webserver` and `site.yml`
- `screenshots/`: evidence of each stage

## Run
    cd terraform && terraform init -backend-config=backend.hcl && terraform apply
    cd ../ansible && ansible all -m ping && ansible-playbook site.yml
    terraform destroy   # when finished (NAT Gateway bills hourly)

Secrets (`.vault_pass`, keys, state, `backend.hcl`) are git-ignored; MongoDB passwords are in Ansible Vault.
