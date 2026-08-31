# Vault policy for the frontend service (Pollpear_frontend).
# May introspect its own token and read the public app configuration
# (frontend, backend and gateway URLs) it needs at runtime.
path "auth/token/lookup-self" { capabilities = ["read"] }
path "secret/data/pollpear/app" { capabilities = ["read"] }
