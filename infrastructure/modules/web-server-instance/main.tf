resource "scaleway_instance_server" "instance" {
  name              = var.instance_name
  type              = var.web_server_type
  image             = var.web_server_image
  private_network {
    pn_id = var.private_network_id
  }
  user_data = var.instance_user_data
}