# Security

## Local signing files

The Android keystore, `keystore.properties`, Apple certificates, provisioning profiles, and App Store Connect keys are local or CI-only secrets. They must never be committed to Git or attached to public issues.

Use `keystore.properties.example` as the local template. GitHub Actions should receive signing material only through encrypted repository or environment secrets.

## If a secret is exposed

1. Revoke or rotate the affected credential immediately.
2. Check Git history and GitHub Actions logs for exposure.
3. Replace the local or CI secret.
4. Record the incident and verification result in the release notes.
