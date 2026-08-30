# PHI Encryption Plan (Active Record Encryption)

Status: **proposed / not yet enabled.** This is a deliberate, staged change — it
touches production health data, so it must not be flipped on in a single deploy.

## Why

The app stores protected health information (PHI) and personal data in plaintext:
Brazilian tax IDs (CPF), phone, address, medications, health conditions, injuries,
and dietary restrictions. For a fitness portal that is a gap; for anything moving
toward a clinical product it is an LGPD exposure. Active Record Encryption (ARE)
encrypts these at the application layer so the values are ciphertext at rest in
Postgres and in backups.

## Scope — what to encrypt

All target columns are free-form and **never used in a `WHERE`/`find_by`**, so they
can use the strongest **non-deterministic** encryption.

**`Anamnese`** (the PHI record):
`cpf`, `phone`, `address`, `health_conditions`, `medications`, `injuries`,
`dietary_restrictions`, and the free-text lifestyle/health fields
(`routine_description`, `expectations`, `personality`, `eating_motivation`, etc.).

**Explicitly NOT in scope (with reasons):**
- `users.email_address` — used as a lookup key in `find_by(email_address:)` (login,
  password reset, registration) and carries a uniqueness index. Encrypting it would
  require **deterministic** encryption (weaker) and reworking the uniqueness path.
  Treat as a separate, optional advanced step; leave plaintext for now.
- `student_profiles.name` / `student_id` — operational identifiers, low sensitivity,
  used in search/sort. Out of scope.

Column types are unlimited `text`/`string`, so the ciphertext expansion (ARE stores a
base64 JSON envelope) needs no schema change.

## Key management (no dependency on `config/master.key`)

Do **not** hardcode keys or require the repo's master key. Provide the three ARE keys
via environment variables so they live in the deploy secret store (Kamal
`.kamal/secrets` / env), not in git:

```ruby
# config/application.rb (or config/initializers/active_record_encryption.rb)
config.active_record.encryption.primary_key            = ENV["AR_ENCRYPTION_PRIMARY_KEY"]
config.active_record.encryption.deterministic_key      = ENV["AR_ENCRYPTION_DETERMINISTIC_KEY"]
config.active_record.encryption.key_derivation_salt    = ENV["AR_ENCRYPTION_KEY_DERIVATION_SALT"]
# Gradual rollout — read still-plaintext rows while writing ciphertext. Flip to
# false only after the backfill (below) has run everywhere.
config.active_record.encryption.support_unencrypted_data = true
```

Generate the three values once with `bin/rails db:encryption:init` (or three
`SecureRandom.alphanumeric(32)` values) and store them as deploy secrets. **Losing
`AR_ENCRYPTION_PRIMARY_KEY` makes the encrypted data unrecoverable — back it up.**

For **test/CI**, set fixed throwaway keys so specs run deterministically, e.g. in
`config/environments/test.rb`:

```ruby
config.active_record.encryption.primary_key         = "test" * 8
config.active_record.encryption.deterministic_key   = "test" * 8
config.active_record.encryption.key_derivation_salt = "test" * 8
```

## Model changes

```ruby
class Anamnese < ApplicationRecord
  encrypts :cpf, :phone, :address,
           :health_conditions, :medications, :injuries, :dietary_restrictions,
           :routine_description, :expectations, :personality, :eating_motivation
  # ...existing validations unchanged (validations run on the decrypted value)
end
```

Note: length validations already in the model operate on the plaintext value, so they
are unaffected.

## Rollout (staged — this is the important part)

1. **Deploy the keys** as env secrets (all environments that hold data).
2. **Deploy `encrypts` + `support_unencrypted_data = true`.** New writes are encrypted;
   existing plaintext rows still read correctly. Zero downtime, reversible.
3. **Backfill** existing rows to ciphertext with a rake task:

   ```ruby
   # lib/tasks/phi_encryption.rake
   namespace :phi do
     desc "Encrypt existing Anamnese PHI in place"
     task backfill: :environment do
       Anamnese.find_each(batch_size: 200) { |a| a.encrypt }  # re-saves as ciphertext
     end
   end
   ```

   Run once per environment (`bin/kamal app exec 'bin/rails phi:backfill'`), ideally
   after a DB backup.
4. **Verify** no plaintext remains (spot-check a row in `dbc`), then set
   `support_unencrypted_data = false` and deploy — from here, plaintext is rejected.

## Testing

- Add a model spec asserting the column is ciphertext at rest and plaintext through the
  accessor, e.g. `Anamnese.connection.select_value("SELECT cpf FROM anamneses WHERE id=…")`
  is not the plaintext, while `anamnese.cpf` is.
- The existing suite should stay green once the test keys above are set (validations and
  factories operate on plaintext accessors).

## Caveats / decisions to make

- **CPF search:** if admins ever need to search by CPF, that column would need
  *deterministic* encryption instead (queryable but weaker). Currently CPF is only
  stored/displayed, so non-deterministic is correct.
- **`email_address`:** left plaintext deliberately (lookup key). Encrypting it is a
  separate deterministic-encryption task with uniqueness-index implications.
- **Sentry:** `send_default_pii` is already off (see `config/initializers/sentry.rb`), so
  decrypted values won't leak to the error tracker.
- **Key rotation** is supported (ARE key sets), but out of scope for the initial rollout.

## Why this isn't in this PR

Enabling encryption is a data migration on live health records with an
unrecoverable-key failure mode. It should land as its own PR, deployed in the staged
order above with a fresh DB backup — not bundled with unrelated changes.
