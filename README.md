# Atleta

A coaching platform for gyms and personal training teams: trainers prescribe
workouts and meal plans, students follow them and log their sessions, and
administrators manage the roster and approve new registrations.

Built with Rails 8. The interface is in Brazilian Portuguese; this README and the
code are in English.

## What's in here

The parts worth looking at, if you're reading this as a code sample:

| Area | Where | Notes |
|---|---|---|
| Authorization | `app/policies/` | Policy objects per resource, with `spec/requests/tenant_isolation_spec.rb` as an end-to-end regression guard that one student cannot reach another's records |
| Service layer | `app/services/` | Multi-step flows (registration, workout sessions, exercise search) kept out of controllers |
| Serializers | `app/serializers/` | View-based JSON rendering (`default`, `summary`, `detailed`) without a serialization gem |
| Background work | `app/jobs/`, `config/recurring.yml` | Solid Queue; a daily job suspends expired plans and notifies students and admins |
| Domain validation | `app/validators/` | CPF and Brazilian phone validators, plus anthropometric range checks |
| Health data | `docs/security/phi-encryption.md` | Anamnesis fields are encrypted at rest; these are *dados sensíveis* under Brazil's LGPD |
| Security headers | `config/initializers/` | Enforcing CSP with per-response script nonces, plus `security_headers.rb` |

## Stack

Ruby 3.4.7 · Rails 8.1 · PostgreSQL · Solid Queue / Cache / Cable · Importmap ·
Tailwind · Stimulus · RSpec · Kamal

## Setup

```bash
docker compose up -d db   # PostgreSQL
bin/setup                 # gems, database, assets, then starts the server
```

`bin/setup --skip-server` prepares the environment without booting. No environment
variables are needed for development or test.

To deploy, generate your own credentials first — this repository ships none:

```bash
bin/rails credentials:edit
```

## Tests

```bash
bundle exec rspec   # 1409 examples
bin/rubocop         # rubocop-rails-omakase
bin/ci              # the full CI suite: specs, lint, Brakeman, bundler-audit
```

## Seed data

`bin/rails db:seed` creates an admin, a student and a partner account, plus
sample exercises and trainings. Credentials are printed at the end of the run.

The nutrition module is designed around TACO, the Brazilian food composition
table published by NEPA/UNICAMP. That dataset is not redistributed here — see
`lib/tasks/import_taco.rake` for how to supply it.

## Known gaps

Stated plainly, because a code sample that pretends to be finished is less useful
than one that knows what it isn't:

- **No i18n extraction.** Locale files exist and `pt-BR` is the default, but view
  copy is hardcoded rather than going through `t()`. Translating the UI means
  editing views.
- **No billing.** There is no payment, subscription or invoicing layer.
- **Single tenant.** Records belong to users, not to an organisation; running
  this for multiple independent gyms would need a scoping layer first.
- **Web only.** No mobile app, and the PWA manifest is not wired up.

## Origin

This began as a client project, built solo in about three weeks. This repository
is a genericized copy published as a code sample: the client's branding, legal
documents, seed data and imagery have been removed, and the history starts fresh.

## License

MIT — see `LICENSE`.
