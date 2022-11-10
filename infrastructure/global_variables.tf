variable "zone" {
  type=string
}
// Is required to call scaleway API for retrieving DHCP information
variable "scw_secret_key" {
  type = string
}