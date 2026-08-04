#!/bin/sh
set -eu

export VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
: "${VAULT_TOKEN:?VAULT_TOKEN requis}"
POLICY_DIR="${POLICY_DIR:-/vault/policies}"
APPROLE_DIR="${APPROLE_DIR:-/vault/approle}"

POSTGRES_USER="${POSTGRES_USER:-pollpear}"
POSTGRES_DB="${POSTGRES_DB:-pollpear}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is not set in .env}"

NESTJS_PEPPER="${NESTJS_PEPPER:?NESTJS_PEPPER is not set in .env}"

# GRAFANA_USER/GRAFANA_PASSWORD: Grafana lit ses creds directement depuis .env (compose.monitor.yml), pas depuis Vault
# GRAFANA_USER="${GRAFANA_USER:-admin}"
# GRAFANA_PASSWORD="${GRAFANA_PASSWORD:?GRAFANA_PASSWORD is not set in .env}"

BACKEND_URL="${BACKEND_URL:-http://backend:3000}"
BACKEND_PORT="${BACKEND_PORT:-3000}"
REDIS_PASSWORD="${REDIS_PASSWORD:?REDIS_PASSWORD is not set in .env}"

MAIL_HOST="${MAIL_HOST:-CHANGE-ME}"
MAIL_PORT="${MAIL_PORT:-587}"
MAIL_USER="${MAIL_USER:-CHANGE-ME}"
MAIL_PASS="${MAIL_PASS:-CHANGE-ME}"
MAIL_FROM="${MAIL_FROM:-CHANGE-ME}"

OAUTH_42_CLIENT_ID="${OAUTH_42_CLIENT_ID:-CHANGE-ME}"
OAUTH_42_CLIENT_SECRET="${OAUTH_42_CLIENT_SECRET:-CHANGE-ME}"
OAUTH_42_REDIRECT_URI="${OAUTH_42_REDIRECT_URI:-https://localhost/auth/oauth/school42/callback}"

OAUTH_GITHUB_CLIENT_ID="${OAUTH_GITHUB_CLIENT_ID:-CHANGE-ME}"
OAUTH_GITHUB_CLIENT_SECRET="${OAUTH_GITHUB_CLIENT_SECRET:-CHANGE-ME}"
OAUTH_GITHUB_REDIRECT_URI="${OAUTH_GITHUB_REDIRECT_URI:-https://localhost/auth/oauth/github/callback}"

OAUTH_GOOGLE_CLIENT_ID="${OAUTH_GOOGLE_CLIENT_ID:-CHANGE-ME}"
OAUTH_GOOGLE_CLIENT_SECRET="${OAUTH_GOOGLE_CLIENT_SECRET:-CHANGE-ME}"
OAUTH_GOOGLE_REDIRECT_URI="${OAUTH_GOOGLE_REDIRECT_URI:-https://localhost/auth/oauth/google/callback}"

GARAGE_S3_ENDPOINT="${GARAGE_S3_ENDPOINT:-http://garage:3900}"
GARAGE_S3_URL="${GARAGE_S3_URL:-http://garage:3902}"
GARAGE_S3_UPLOADS_HOST="${GARAGE_S3_UPLOADS_HOST:-pollpear-uploads.web.garage.localhost}"
GARAGE_S3_REGION="${GARAGE_S3_REGION:-garage}"
GARAGE_S3_BUCKET="${GARAGE_S3_BUCKET:-pollpear-uploads}"
GARAGE_S3_ACCESS_KEY="${GARAGE_S3_ACCESS_KEY:-CHANGE-ME}"
GARAGE_S3_SECRET_KEY="${GARAGE_S3_SECRET_KEY:-CHANGE-ME}"

FRONTEND_URL="${FRONTEND_URL:-http://localhost:5173}"
GATEWAY_URL="${GATEWAY_URL:-http://localhost:8080}"

WS_PATH="${WS_PATH:-/ws}"
WS_PING_INTERVAL="${WS_PING_INTERVAL:-25000}"
WS_PING_TIMEOUT="${WS_PING_TIMEOUT:-20000}"
WS_MAX_PAYLOAD="${WS_MAX_PAYLOAD:-1000000}"

SERVICES="pollpear-backend pollpear-gateway pollpear-ai pollpear-postgres pollpear-redis pollpear-redis-exporter pollpear-grafana pollpear-prometheus pollpear-frontend"

until vault status >/dev/null 2>&1; do sleep 1; done

vault secrets enable -path=secret kv-v2 2>/dev/null || true

DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?schema=public"

vault kv put secret/pollpear/db \
  host=postgres port=5432 database="$POSTGRES_DB" username="$POSTGRES_USER" \
  password="$POSTGRES_PASSWORD" database_url="$DATABASE_URL"
vault kv put secret/pollpear/redis host=redis port=6379 password="$REDIS_PASSWORD"
vault kv put secret/pollpear/session ttl=86400 pepper="$NESTJS_PEPPER"
vault kv put secret/pollpear/oauth/google client_id="$OAUTH_GOOGLE_CLIENT_ID" client_secret="$OAUTH_GOOGLE_CLIENT_SECRET" redirect_uri="$OAUTH_GOOGLE_REDIRECT_URI"
vault kv put secret/pollpear/oauth/github client_id="$OAUTH_GITHUB_CLIENT_ID" client_secret="$OAUTH_GITHUB_CLIENT_SECRET" redirect_uri="$OAUTH_GITHUB_REDIRECT_URI"
vault kv put secret/pollpear/oauth/42 client_id="$OAUTH_42_CLIENT_ID" client_secret="$OAUTH_42_CLIENT_SECRET" redirect_uri="$OAUTH_42_REDIRECT_URI"
vault kv put secret/pollpear/mail host="$MAIL_HOST" port="$MAIL_PORT" user="$MAIL_USER" pass="$MAIL_PASS" from="$MAIL_FROM"
vault kv put secret/pollpear/s3 endpoint="$GARAGE_S3_ENDPOINT" url="$GARAGE_S3_URL" region="$GARAGE_S3_REGION" bucket="$GARAGE_S3_BUCKET" access_key="$GARAGE_S3_ACCESS_KEY" secret_key="$GARAGE_S3_SECRET_KEY" uploads_host="$GARAGE_S3_UPLOADS_HOST"
vault kv put secret/pollpear/app frontend_url="$FRONTEND_URL" backend_url="$BACKEND_URL" gateway_url="$GATEWAY_URL" backend_port="$BACKEND_PORT"
vault kv put secret/pollpear/ws path="$WS_PATH" ping_interval="$WS_PING_INTERVAL" ping_timeout="$WS_PING_TIMEOUT" max_payload="$WS_MAX_PAYLOAD"
# secret/pollpear/ai/keys: aucun consommateur dans Pollpear_ai pour l'instant, désactivé
# vault kv put secret/pollpear/ai/keys ml=""
# secret/pollpear/grafana: Grafana ne lit pas Vault, désactivé
# vault kv put secret/pollpear/grafana admin_user="$GRAFANA_USER" admin_password="$GRAFANA_PASSWORD"

for s in $SERVICES; do
  vault policy write "$s" "$POLICY_DIR/$s.hcl"
done

vault auth enable approle 2>/dev/null || true
mkdir -p "$APPROLE_DIR"
for s in $SERVICES; do
  vault write "auth/approle/role/$s" \
    token_policies="$s" token_ttl=1h token_max_ttl=4h \
    secret_id_ttl=0 secret_id_num_uses=0 >/dev/null

  role_id="$(vault read -field=role_id "auth/approle/role/$s/role-id")"
  secret_id="$(vault write -f -field=secret_id "auth/approle/role/$s/secret-id")"

  printf 'ROLE_ID=%s\nSECRET_ID=%s\n' "$role_id" "$secret_id" > "$APPROLE_DIR/$s.env"
  chmod 0644 "$APPROLE_DIR/$s.env"
done

echo "[seed] Vault seeded: ${SERVICES}"
