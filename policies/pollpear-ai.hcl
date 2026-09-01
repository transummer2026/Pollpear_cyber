# Vault policy for the AI service (Pollpear_ai).
# Read-only access to the AI secret subtree and the shared database credentials.
path "secret/data/pollpear/ai/*" { capabilities = ["read"] }
path "secret/data/pollpear/db"   { capabilities = ["read"] }
