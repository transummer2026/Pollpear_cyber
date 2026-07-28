#!/bin/sh
set -eu

export VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
: "${VAULT_TOKEN:?VAULT_TOKEN requis}"
POLICY_DIR="${POLICY_DIR:-/vault/policies}"
APPROLE_DIR="${APPROLE_DIR:-/vault/approle}"

PG_USER="${PG_USER:-pollpear}"
PG_DB="${PG_DB:-pollpear}"
PG_PASSWORD="${PG_PASSWORD:-ShPzwUT7pftfbXrwYWj5xiAmwMrUOfLW}"
REDIS_PASSWORD="${REDIS_PASSWORD:-aLjakN0BByXYu7CXM3ODZrMlTOGlevoL}"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-QnqVNUzngXww7H0ynRpIrx2fm7Yon}"
SESSION_COOKIE_SECRET="${SESSION_COOKIE_SECRET:-54fb853bb5d862738a1122f933b092ad23bc0d492c0e2932448ced42c92f1db7}"
API_KEYS_PEPPER="${API_KEYS_PEPPER:-0140f0f32b7db543a154dd9468aa70e5fafcf7462a2f33ec406aa15906ba35c0}"
NESTJS_PEPPER="${NESTJS_PEPPER:-9c1b0e7d4a2f6538b1e0c9a7d4f2b6e8c3a5079d1f4b8e2c6a0d3f7b5e9c1a4d}"
OAUTH_42_CLIENT_ID="${OAUTH_42_CLIENT_ID:-CHANGE-ME}"
OAUTH_42_CLIENT_SECRET="${OAUTH_42_CLIENT_SECRET:-CHANGE-ME}"
OAUTH_42_REDIRECT_URI="${OAUTH_42_REDIRECT_URI:-https://localhost/auth/oauth/school42/callback}"
OAUTH_GOOGLE_CLIENT_ID="${OAUTH_GOOGLE_CLIENT_ID:-CHANGE-ME}"
OAUTH_GOOGLE_CLIENT_SECRET="${OAUTH_GOOGLE_CLIENT_SECRET:-CHANGE-ME}"
OAUTH_GOOGLE_REDIRECT_URI="${OAUTH_GOOGLE_REDIRECT_URI:-https://localhost/auth/oauth/google/callback}"
OAUTH_GITHUB_CLIENT_ID="${OAUTH_GITHUB_CLIENT_ID:-CHANGE-ME}"
OAUTH_GITHUB_CLIENT_SECRET="${OAUTH_GITHUB_CLIENT_SECRET:-CHANGE-ME}"
OAUTH_GITHUB_REDIRECT_URI="${OAUTH_GITHUB_REDIRECT_URI:-https://localhost/auth/oauth/github/callback}"
MAIL_HOST="${MAIL_HOST:-CHANGE-ME}"
MAIL_PORT="${MAIL_PORT:-587}"
MAIL_USER="${MAIL_USER:-CHANGE-ME}"
MAIL_PASS="${MAIL_PASS:-CHANGE-ME}"
MAIL_FROM="${MAIL_FROM:-CHANGE-ME}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:5173}"
GARAGE_S3_ENDPOINT="${GARAGE_S3_ENDPOINT:-http://garage:3900}"
GARAGE_S3_REGION="${GARAGE_S3_REGION:-garage}"
GARAGE_S3_BUCKET="${GARAGE_S3_BUCKET:-pollpear-uploads}"
GARAGE_S3_ACCESS_KEY="${GARAGE_S3_ACCESS_KEY:-CHANGE-ME}"
GARAGE_S3_SECRET_KEY="${GARAGE_S3_SECRET_KEY:-CHANGE-ME}"

SERVICES="pollpear-backend pollpear-gateway pollpear-ai pollpear-postgres pollpear-redis pollpear-grafana pollpear-prometheus pollpear-frontend"

until vault status >/dev/null 2>&1; do sleep 1; done

vault secrets enable -path=secret kv-v2 2>/dev/null || true

DATABASE_URL="postgresql://${PG_USER}:${PG_PASSWORD}@postgres:5432/${PG_DB}?schema=public"

vault kv put secret/pollpear/db \
  host=postgres port=5432 database="$PG_DB" username="$PG_USER" \
  password="$PG_PASSWORD" database_url="$DATABASE_URL"
vault kv put secret/pollpear/redis host=redis port=6379 password="$REDIS_PASSWORD"
vault kv put secret/pollpear/session ttl=86400 cookie_secret="$SESSION_COOKIE_SECRET" pepper="$NESTJS_PEPPER"
vault kv put secret/pollpear/api-keys pepper="$API_KEYS_PEPPER"
vault kv put secret/pollpear/oauth/google client_id="$OAUTH_GOOGLE_CLIENT_ID" client_secret="$OAUTH_GOOGLE_CLIENT_SECRET" redirect_uri="$OAUTH_GOOGLE_REDIRECT_URI"
vault kv put secret/pollpear/oauth/github client_id="$OAUTH_GITHUB_CLIENT_ID" client_secret="$OAUTH_GITHUB_CLIENT_SECRET" redirect_uri="$OAUTH_GITHUB_REDIRECT_URI"
vault kv put secret/pollpear/oauth/42 client_id="$OAUTH_42_CLIENT_ID" client_secret="$OAUTH_42_CLIENT_SECRET" redirect_uri="$OAUTH_42_REDIRECT_URI"
vault kv put secret/pollpear/mail host="$MAIL_HOST" port="$MAIL_PORT" user="$MAIL_USER" pass="$MAIL_PASS" from="$MAIL_FROM"
vault kv put secret/pollpear/s3 endpoint="$GARAGE_S3_ENDPOINT" region="$GARAGE_S3_REGION" bucket="$GARAGE_S3_BUCKET" access_key="$GARAGE_S3_ACCESS_KEY" secret_key="$GARAGE_S3_SECRET_KEY"
vault kv put secret/pollpear/app frontend_url="$FRONTEND_URL"
vault kv put secret/pollpear/ai/keys ml=""
vault kv put secret/pollpear/grafana admin_user="$GRAFANA_USER" admin_password="$GRAFANA_PASSWORD"

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
