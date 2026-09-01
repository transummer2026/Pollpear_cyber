# Vault policy for the Prometheus monitoring service.
# Prometheus stores no application secret in Vault; it may only introspect its own
# token. Scrape targets are configured outside Vault.
path "auth/token/lookup-self" { capabilities = ["read"] }
