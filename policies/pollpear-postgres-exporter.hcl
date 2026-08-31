# Vault policy for the Postgres metrics exporter (Prometheus postgres_exporter).
# Read-only access to the database credentials it uses to connect and scrape.
path "secret/data/pollpear/db"     { capabilities = ["read"] }
path "secret/metadata/pollpear/db" { capabilities = ["read"] }
