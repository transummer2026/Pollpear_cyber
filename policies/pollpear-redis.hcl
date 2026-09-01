# Vault policy for the Redis service.
# Read-only access to its own credentials (password).
path "secret/data/pollpear/redis"     { capabilities = ["read"] }
path "secret/metadata/pollpear/redis" { capabilities = ["read"] }
