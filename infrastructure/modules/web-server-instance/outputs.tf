output "private_ip" {
  value = scaleway_instance_server.instance.private_ip
}
output "private_ip_dhcp" {
  value = trim(trimspace(data.local_file.private_ip_instance.content), "\"")
}

output "name" {
  value=var.instance_name
}