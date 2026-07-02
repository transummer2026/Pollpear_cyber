FROM hashicorp/vault:2.0@sha256:a296a888b118615dc01d5f1a6846e6d4a7277946caaed5b447008fff5fe06b54

ENV VAULT_ADDR=http://127.0.0.1:8200

ENV VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200

COPY config/vault.hcl /vault/config-prod/vault.hcl
COPY policies/        /vault/policies/
COPY seed.sh          /usr/local/bin/seed.sh

USER root
RUN mkdir -p /vault/approle \
 && chown vault:vault /vault/approle \
 && chmod +x /usr/local/bin/seed.sh
USER vault

EXPOSE 8200

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD vault status || exit 1
