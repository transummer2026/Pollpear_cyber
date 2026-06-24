FROM hashicorp/vault:2.0@sha256:a296a888b118615dc01d5f1a6846e6d4a7277946caaed5b447008fff5fe06b54

ENV VAULT_ADDR=http://127.0.0.1:8200

ENV VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200

EXPOSE 8200

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD vault status || exit 1
