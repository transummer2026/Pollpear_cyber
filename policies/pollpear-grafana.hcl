# Vault policy for the Grafana service.
# Read-only access to the Grafana admin credentials and their metadata.
path "secret/data/pollpear/grafana"     { capabilities = ["read"] }
path "secret/metadata/pollpear/grafana" { capabilities = ["read"] }
