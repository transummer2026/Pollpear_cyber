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

SERVICES="pollpear-backend pollpear-gateway pollpear-ai pollpear-postgres pollpear-redis pollpear-grafana pollpear-prometheus pollpear-frontend"

until vault status >/dev/null 2>&1; do sleep 1; done

vault secrets enable -path=secret kv-v2 2>/dev/null || true

DATABASE_URL="postgresql://${PG_USER}:${PG_PASSWORD}@postgres:5432/${PG_DB}?schema=public"

vault kv put secret/pollpear/db \
  host=postgres port=5432 database="$PG_DB" username="$PG_USER" \
  password="$PG_PASSWORD" database_url="$DATABASE_URL"
vault kv put secret/pollpear/redis host=redis port=6379 password="$REDIS_PASSWORD"
vault kv put secret/pollpear/session ttl=86400 cookie_secret="$SESSION_COOKIE_SECRET"
vault kv put secret/pollpear/api-keys pepper="$API_KEYS_PEPPER"
vault kv put secret/pollpear/oauth/google client_id=CHANGE-ME client_secret=CHANGE-ME redirect_uri="https://localhost/auth/oauth/google/callback"
vault kv put secret/pollpear/oauth/42 client_id=CHANGE-ME client_secret=CHANGE-ME redirect_uri="https://localhost/auth/oauth/42/callback"
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
