//The Load Balancer will be responsible here to expose nginx service 
//deployed through ansible configuration
variable "load_balancer_static_ip" {
  type = list(string)
}
resource "scaleway_lb_ip" "lb_ip" {
  zone = var.zone
}
resource "scaleway_lb" "lb" {
  ip_id = scaleway_lb_ip.lb_ip.id
  zone  = var.zone
  type  = "LB-S"
  private_network {
    private_network_id = scaleway_vpc_private_network.pn1.id
    static_config      = var.load_balancer_static_ip
  }
}

resource "scaleway_lb_frontend" "frontend_simple_metadata_server" {
  lb_id        = scaleway_lb.lb.id
  backend_id   = scaleway_lb_backend.nginx_backend.id
  inbound_port = "80"
  name         = "simple_metadata_frontend"

}

resource "scaleway_lb_backend" "nginx_backend" {
  lb_id            = scaleway_lb.lb.id
  forward_protocol = "http"
  name             = "ansible_nginx_backend"
  forward_port     = "80"
  //Here we can choose the multiple algorithm roundrobin, leastconn and first.
  forward_port_algorithm = "roundrobin"
  server_ips             = concat(module.ubuntu_hosts.*.private_ip_dhcp, module.centos_hosts.*.private_ip_dhcp)
  depends_on = [
    module.ubuntu_hosts,
    module.centos_hosts
  ]
}

output "service_ip" {
  value = "http://${scaleway_lb.lb.ip_address}"
}