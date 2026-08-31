# Vault policy for the Redis metrics exporter (Prometheus redis_exporter).
# Read-only access to the Redis credentials it uses to connect and scrape.
path "secret/data/pollpear/redis"     { capabilities = ["read"] }
path "secret/metadata/pollpear/redis" { capabilities = ["read"] }
