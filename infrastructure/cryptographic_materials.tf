# Generate TLS key that will be used to connect between each Ansible SSH
resource "tls_private_key" "scw_ssh_key" {
  algorithm = "ED25519"
}

resource "scaleway_account_ssh_key" "main" {
    name        = "ansible_key"
    public_key = tls_private_key.scw_ssh_key.public_key_openssh
}