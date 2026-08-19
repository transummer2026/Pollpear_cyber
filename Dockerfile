FROM ghcr.io/transummer2026/vault@sha256:a296a888b118615dc01d5f1a6846e6d4a7277946caaed5b447008fff5fe06b54

ENV VAULT_ADDR=http://127.0.0.1:8200
ENV VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200

WORKDIR /vault

USER root
RUN apk add --no-cache apache2-utils
RUN mkdir -p approle config-prod policies \
 && chown -R vault:vault /vault

COPY --chown=vault:vault config/vault.hcl config-prod/vault.hcl
COPY --chown=vault:vault policies/        policies/
COPY --chown=vault:vault seed.sh          /usr/local/bin/seed.sh
RUN chmod +x /usr/local/bin/seed.sh

USER vault

EXPOSE 8200

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD vault status || exit 1
