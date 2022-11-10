# Overview

Project that combines Ansible and Terraform to deliver infrastructure within Scaleway VPC Context.

![Archi Description](./docs/resources/images/archi_description.png)

The architecture can be subdivided in two parts : 
- Provisioning/Configuration Mananagement
- Service Access

## Provisioning
Terraform will be used from an admin local computer to deploy the whole architecture that contains the following :
- VPC (Private Network & Public Gateway)
- Load Balancer
- Ubuntu Controller(i.e : Ansible Pre Installed through Cloud Init)
- Ubuntu & Centos Web Server Hosts
- SSH Keys Generation (i.e. those keys are added as project keys so that they can be use to access any server and are also put as ssh key on the controller so that it can access to every server)
- Nginx Playbook sources Copy in the controller
- Ansible Configuration Generation in Ansible Controller
    - Static Inventory
    - Default Configuration
The inventory will be on the following form :
```
[ubuntu]
ubuntu-server-0
ubuntu-server-1
[centos]
centos-server-0
centos-server-1
[linux:children]
centos
ubuntu
```

Hosts are gathered under the linux category which have 2 sub categories centos and ubuntu. This allow us to customize our ansible configuration depending on the nature of the host.

## Configuration Management
Ansible will be in charge of deploying Nginx web server on the targeted web server through our controller. 
It will be accessible using the Public Gateway bastion. 

```ssh -J bastion@$bastion_ip:61000 $user@ansible-controller.ansible-pn```

## Service Access
The Nginx Service will be accessible through the Load Balancer that has been configured to automatically Round Robin between the web servers.

# Deployment
## Prerequisites
- Terraform
- [Scaleway API Keys](https://www.scaleway.com/en/docs/console/my-project/how-to/generate-api-key/): For security reasons, the secret key retrieved must be put as environment variable **TF_VAR_scw_secret_key**, otherwise it can be written directly within terraform files.

## Infrastructure
1. Open infrastructure folder with a cmd
2. Copy terraform.tfvars.template -> terraform.tfvars (Fill it with your properties controller node type , zone , ...)
3. Copy provider.tf.template -> provider.tf (Fill it with your Scaleway Data region, zone ..)
2. terraform init
3. terraform plan (i.e. if you wan to check components that will be deployed)
4. terraform apply -auto-approve


## Application Deployment
The infrastructure deployment step has also added the ansible-playbooks source in this project within the Ansible Controller Server. So that it can be executed once the infrastructure has been delivered. The command to be used has been defined as  output of the terraform script "ansible_playbook_deploy".
```ansible_playbook_deploy = "ssh -J bastion@bastion_ip:61000 root@ansible-controller.ansible-pn ansible-playbook  /root/ansible-playbooks/nginx_playbook.yaml"```

This output value should be copied and executed within a command for nginx deployment to happen.

![Ansible App Deployment](./docs/resources/images/ansible_app_deployment.png)

The Nginx Application deployed will be accessible from the Load Balancer Public IP. It can be retrieved from the terraform output **service_address**
# Notes
This example can also be used as Sandbox for Ansible deployment by using your own playbooks or Role from Galaxy. 
# Warning 
- Ansible inventory is static and generated just once (So if you add a server you should update it manually)
- root user is static (To be fix)
- Playbook source is copy once and not synchronized