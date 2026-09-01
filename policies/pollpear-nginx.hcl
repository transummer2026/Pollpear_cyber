# Vault policy for the nginx reverse proxy / ModSecurity WAF.
# Read-only access to the nginx (htpasswd, auth toggle) and WAF configuration
# secrets, including their metadata.
path "secret/data/pollpear/nginx"     { capabilities = ["read"] }
path "secret/metadata/pollpear/nginx" { capabilities = ["read"] }
path "secret/data/pollpear/waf"     { capabilities = ["read"] }
path "secret/metadata/pollpear/waf" { capabilities = ["read"] }
