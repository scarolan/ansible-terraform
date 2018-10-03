# Ansible and Terraform - Better Together
This repository contains code examples for running Terraform and Ansible together in different configurations.

## Run Ansible from Terraform
### With `local_exec`
Use the code examples in the `terraform_gcp` or `terraform_azure` folders to see how this is done. Basically there are two steps. First is a remote exec which forces Terraform to wait until SSH is running to run Ansible. This can be anything, even an `echo "Hello World"` command. Then we execute an `ansible-playbook` command from the same machine where we ran `terraform apply`.

### With `remote_exec`
The code example in the `terraform_gcp` directory has code for remote exec commented out. You can comment out the local_exec code and run this to have Ansible run on the remote host. With this method we first copy our playbook to the remote host, then we install and run Ansible locally there.

## Run Terraform from Ansible
Ansible has a Terraform module that can trigger Terraform deployments and plans. You can also pull resource information back into Ansible:
https://docs.ansible.com/ansible/devel/modules/terraform_module.html

## Build System Images with Packer and Ansible
HashiCorp's Packer tool allows you to use your existing Ansible playbooks to easily build machine images on the cloud or virtualization platform of your choice. Packer uses a JSON file for configuration, and is run from the command line. 

## Integrate HashiCorp Vault with Ansible
You can easily fetch secrets from Vault using the Hashi Vault Ansible plugin:
https://docs.ansible.com/ansible/devel/plugins/lookup/hashi_vault.html

This plugin is based on the excellent Python HVAC library:
https://github.com/hvac/hvac