locals {
  data_path="${path.module}/data"
  controller_instance_name="ansible-controller"
}
variable "ansible_controller_node_type" {
  type=string
}
data "local_file" "ansible_config" {
    filename = "${local.data_path}/files/ansible.cfg"
}

data "local_file" "nginx_playbook" {
  filename = "${path.module}/../ansible-playbooks/nginx_playbook.yaml"
}


resource "scaleway_instance_server" "ansible-controller" {
  name  = local.controller_instance_name
  type  =  var.ansible_controller_node_type
  image = "ubuntu_jammy"
  // It does not seem to be possible to have both Flexible IP and Dynamic IP
  private_network {
    pn_id = scaleway_vpc_private_network.pn1.id
  }
  //With user Data
  // We write the ansible config , the certs that will be used by the ansible control and the hosts file
  //We write the playbook
  user_data = {
    cloud-init = <<-EOT
    #cloud-config
    packages_update: true
    packages_upgrade: true
    packages:
      - ansible
    write_files:
      - content: ${jsonencode(tls_private_key.scw_ssh_key.private_key_openssh)}
        path: /root/.ssh/id_ed25519
        permissions: '0600'
      - content: ${tls_private_key.scw_ssh_key.public_key_openssh}
        path: /root/.ssh/id_ed25519.pub
        permissions: '0660'
      - content: ${jsonencode(data.local_file.ansible_config.content)}
        path: /root/.ansible.cfg
      - content: ${jsonencode(local.ansible_hosts)}
        path: /root/hosts
      - content: ${jsonencode(data.local_file.nginx_playbook.content)}
        path: /root/ansible-playbooks/nginx_playbook.yaml
    EOT
  }
  tags = ["ansible-controller"]
}

locals {
  ansible_hosts=templatefile("${local.data_path}/templates/hosts.tftpl",{ubuntu_servers=module.ubuntu_hosts,centos_hosts=module.centos_hosts})
  controller_ssh_command_base="ssh -J bastion@${local.bastion_address} root@${local.controller_instance_name}.${local.pn_name}"
}

output "controller_ssh_command_base" {
  value = local.controller_ssh_command_base
}
output "ansible_playbook_deploy" {
  value="${local.controller_ssh_command_base} ansible-playbook  /root/ansible-playbooks/nginx_playbook.yaml"
}