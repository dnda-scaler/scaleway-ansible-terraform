
locals {
  ip_filename = "${path.module}/${var.instance_name}_${random_id.web_server_ip_salt.hex}_private_ips.txt"
}

resource "random_id" "web_server_ip_salt" {
  keepers = {
    instance_name = var.instance_name
  }
  byte_length = 8
}

resource "null_resource" "ip_setup_ok" {
  depends_on = [scaleway_instance_server.instance]
  //Retrieve the dhcp entries
  provisioner "local-exec" {

    command     = <<-EOT
curl --location --request GET "https://api.scaleway.com/vpc-gw/v1/zones/fr-par-1/dhcp-entries" -H "X-Auth-Token: ${var.scaleway_secret_key}" | jq '.dhcp_entries[]|select(.hostname=="${var.instance_name}")|.ip_address'> ${local.ip_filename}
EOT
    interpreter = ["bash", "-c"]
  }
  triggers = {
    always_run = timestamp()
  }
}

data "local_file" "private_ip_instance" {
  depends_on = [null_resource.ip_setup_ok]
  filename   = "${local.ip_filename}"
}
