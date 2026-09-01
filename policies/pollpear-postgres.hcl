# Vault policy for the Postgres database service.
# Read-only access to its own credentials (user, password, database name).
path "secret/data/pollpear/db"     { capabilities = ["read"] }
path "secret/metadata/pollpear/db" { capabilities = ["read"] }
