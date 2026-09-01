# Vault policy for the Garage object-storage service.
# Read-only access to the Garage cluster secrets (RPC secret, admin token) and to
# the S3 credentials and bucket configuration, including their metadata.
path "secret/data/pollpear/garage"     { capabilities = ["read"] }
path "secret/metadata/pollpear/garage" { capabilities = ["read"] }
path "secret/data/pollpear/s3"         { capabilities = ["read"] }
path "secret/metadata/pollpear/s3"     { capabilities = ["read"] }
