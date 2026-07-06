path "secret/data/pollpear/db"       { capabilities = ["read"] }
path "secret/data/pollpear/redis"    { capabilities = ["read"] }
path "secret/data/pollpear/session"  { capabilities = ["read"] }
path "secret/data/pollpear/api-keys" { capabilities = ["read"] }
path "secret/data/pollpear/oauth/*"  { capabilities = ["read"] }
path "secret/metadata/pollpear/*"    { capabilities = ["list"] }
