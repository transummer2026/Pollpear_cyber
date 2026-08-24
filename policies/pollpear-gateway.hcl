path "secret/data/pollpear/redis"    { capabilities = ["read"] }
path "secret/data/pollpear/rate_limit { capabilities = ["read] }
path "secret/data/pollpear/session"  { capabilities = ["read"] }
# path "secret/data/pollpear/api-keys" { capabilities = ["read"] } # secret non écrit, aucun consommateur
path "secret/data/pollpear/s3"       { capabilities = ["read"] }
path "secret/data/pollpear/app"      { capabilities = ["read"] }
path "secret/data/pollpear/ws"       { capabilities = ["read"] }
