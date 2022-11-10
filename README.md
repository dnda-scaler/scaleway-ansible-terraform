# scaleway-ansible-terraform
Project that combines ansible and terraform to deliver infrastructure and configuration on scaleway infrastructure. VPC Context
# Infrastructure
Terraform will be used to provide underlying infrastructure which will perform the following :
- Ubuntu Controller  with ansible installed (through Cloud init)
- Scaleway Credentials update within 
- 2*Ubuntu Server 
- 1* Centos Server
- SSH Key Generation
- Ansible Configuration Generation (including static hosts group)
    following model
    [ubuntu]
ansible-ubuntu-0
ansible-u
[centos]
[linux:children]
centos
ubuntu
tf_var_secret_key
# Ansible
Ansible will be here used for applications deployment on our instance
# Deployment
# TODO Add schema
## Prerequisites
- Terraform
## Infrastructure
1. Rename terraform.tfvars.template -> terraform.tfvars
2. Rename provider.tf.template -> provider.tf
3. Provide provider info
4. Fill the terraform.tfvars
5. terraform init 
6. terraform apply
# Disclaimer 
Static Hosts