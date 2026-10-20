# Pollpear_cyber

The secret management layer: HashiCorp Vault's configuration, one least-privilege policy
per service, and the seed script that provisions them. No service in Pollpear ships a
secret in its image — each one authenticates to Vault and fetches what it needs.

Part of **[Pollpear](https://github.com/transummer2026/Pollpear)**, a real-time collaborative polling platform.

## What is in here

| Path | Role |
| :--- | :--- |
| `config/vault.hcl` | The Vault server configuration |
| `policies/` | One `.hcl` policy per consumer — backend, frontend, gateway, ai, postgres, redis, garage, nginx, prometheus, grafana and the two exporters |
| `seed.sh` | Runs once at startup: fills the KV store, writes every policy, and provisions one AppRole per service |
| `Dockerfile` | The Vault image used by the stack |

## How it works

`seed.sh` reads its values from the environment — optionally from a mounted dotenv file
— and fails fast on any missing one, so a half-provisioned Vault never starts. It then
creates an **AppRole per service**, which is what lets each container authenticate
without anyone sharing the root token. Each AppRole is bound to the matching policy in
`policies/`, so a compromised service can read its own secrets and nothing else.

## Running it

Vault comes up with the rest of the stack:

```sh
git clone --recursive https://github.com/transummer2026/Pollpear.git
cd Pollpear && make up_prod
```

The values `seed.sh` consumes are not versioned. `.env.example` lists what is expected;
the real file is obtained from the team.

Full setup instructions live in the [superproject README](https://github.com/transummer2026/Pollpear#readme).
