variable "web_server_type" {
  type = string
}

variable "web_server_image" {
  type = string
}

variable "private_network_id" {
  type = string
}

variable "instance_name" {
  type = string
}

// Is required to call scaleway API for retrieving DHCP information
variable "scaleway_secret_key" {
  type = string
}


variable "instance_user_data" {
  type=object({
    cloud-init =string
  })
}