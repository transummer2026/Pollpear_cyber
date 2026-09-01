# HashiCorp Vault server configuration (single node, non-HA).
# File storage backend: state is persisted to a local volume, with no external
# dependency. Simple, but not suitable for high availability.
storage "file" {
  path = "/vault/file"
}

# API listener. TLS is terminated upstream (reverse proxy on the internal Docker
# network), so Vault itself speaks plain HTTP here (tls_disable = 1).
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

# Address Vault advertises to clients for API redirects.
api_addr = "http://0.0.0.0:8200"

# Serve the built-in web UI.
ui = true 

# The container is not granted CAP_IPC_LOCK, so mlock() would fail; disabling it is
# acceptable here because host/container swap is turned off.
disable_mlock = true
