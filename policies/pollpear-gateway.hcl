# Vault policy for the gateway service (Pollpear_gateway).
# Read-only access to the secrets the gateway needs: Redis, rate limiting, session
# pepper, S3, app config and WebSocket settings.
path "secret/data/pollpear/redis"    { capabilities = ["read"] }
path "secret/data/pollpear/rate_limit" { capabilities = ["read"] }
path "secret/data/pollpear/session"  { capabilities = ["read"] }
# path "secret/data/pollpear/api-keys" { capabilities = ["read"] } # secret not written yet, no consumer
path "secret/data/pollpear/s3"       { capabilities = ["read"] }
path "secret/data/pollpear/app"      { capabilities = ["read"] }
path "secret/data/pollpear/ws"       { capabilities = ["read"] }
