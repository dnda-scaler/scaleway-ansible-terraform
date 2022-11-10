variable "ubuntu_host_count" {
  type = number
  validation {
    condition     = var.ubuntu_host_count > 0 && var.ubuntu_host_count <= 5
    error_message = "Ubuntu hosts must have at least one instance and no more than 5 instances"
  }
}
variable "ubuntu_hosts_node_type" {
  type = string
}

variable "centos_host_count" {
  type = number
  validation {
    condition     = var.centos_host_count > 0 && var.centos_host_count <= 5
    error_message = "Centos hosts must have at least one instance and no more than 5 instances"
  }
}
variable "centos_hosts_node_type" {
  type = string
}

// Use a custom module to be able to retrieve private IP from DHCP
module "ubuntu_hosts" {
  count              = var.ubuntu_host_count
  source             = "./modules/web-server-instance"
  private_network_id = scaleway_vpc_private_network.pn1.id
  web_server_image   = "ubuntu_jammy"
  web_server_type    = var.ubuntu_hosts_node_type
  instance_name      = "ansible-ubuntu-${count.index}"
  instance_user_data = {
    cloud-init = <<-EOT
    #cloud-config
    system_info:
      default_user:
        name: ansible
        sudo: ALL=(ALL) NOPASSWD:ALL
    packages_update: true
    packages_upgrade: true
    EOT
  }
  scaleway_secret_key = var.scw_secret_key
  depends_on = [
    scaleway_account_ssh_key.main
  ]
}

module "centos_hosts" {
  count              = var.centos_host_count
  source             = "./modules/web-server-instance"
  private_network_id = scaleway_vpc_private_network.pn1.id
  web_server_image   = "centos_stream_9"
  web_server_type    = var.centos_hosts_node_type
  instance_name      = "ansible-centos-${count.index}"
  instance_user_data = {
    cloud-init = <<-EOT
    #cloud-config
    system_info:
      default_user:
        name: ansible
        sudo: ALL=(ALL) NOPASSWD:ALL
    packages_update: true
    packages_upgrade: true
    EOT
  }
  scaleway_secret_key = var.scw_secret_key
  depends_on = [
    scaleway_account_ssh_key.main
  ]
}
