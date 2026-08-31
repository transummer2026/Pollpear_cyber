# Vault policy for the backend API (Pollpear_backend, NestJS).
# Read-only access to every secret the API consumes: database, Redis, session
# pepper, OAuth providers, mail, S3, app config, WebSocket and rate limiting.
# The metadata list capability lets it enumerate the available secret names.
path "secret/data/pollpear/db"       { capabilities = ["read"] }
path "secret/data/pollpear/redis"    { capabilities = ["read"] }
path "secret/data/pollpear/session"  { capabilities = ["read"] }
# path "secret/data/pollpear/api-keys" { capabilities = ["read"] } # secret not written yet, no consumer
path "secret/data/pollpear/oauth/*"  { capabilities = ["read"] }
path "secret/data/pollpear/mail"     { capabilities = ["read"] }
path "secret/data/pollpear/s3"       { capabilities = ["read"] }
path "secret/data/pollpear/app"      { capabilities = ["read"] }
path "secret/data/pollpear/ws"       { capabilities = ["read"] }
path "secret/data/pollpear/rate_limit" { capabilities = ["read"] }
path "secret/metadata/pollpear/*"    { capabilities = ["list"] }
