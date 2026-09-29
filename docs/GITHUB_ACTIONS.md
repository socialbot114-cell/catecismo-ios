# GitHub Actions

The normal Android workflow runs content validation, shared JVM tests, Android unit tests, lint, and a debug build on every push and pull request.

The release workflow is manual. Configure these encrypted repository secrets before using it:

- `ANDROID_KEYSTORE_BASE64`: base64 do arquivo de assinatura Android
- `ANDROID_KEYSTORE_PASSWORD`: current PKCS12 password
- `ANDROID_KEY_PASSWORD`: current PKCS12 key password

The iOS App Store workflow is manual and uses the `macos-15` runner with Xcode 26. The Apple Team ID is `SRN7AW424S`. It builds and signs an IPA, updates the Portuguese-Brazil App Store URLs from `store-kit/metadata`, and uploads the binary through Fastlane Deliver. Select `confirm_app_store_submission` when dispatching it to submit to App Review and release automatically after approval; otherwise it uploads the build without submitting it.

The manual `Update App Store listing URLs` workflow runs on Ubuntu and uses the App Store Connect API to ensure the 1.2.1 draft and set its privacy and support URLs from `store-kit/metadata/pt-BR/`; it does not upload a build or change screenshots.

The `Publish project website` workflow deploys `site/` to GitHub Pages when those files change on `main` or `socialbot114-cell/pufferfish`.

The first app record still must exist in App Store Connect. Create it with bundle ID `br.com.CATECISMO.DAIGREJACAToLICA`, name `Catecismo`, a unique SKU, and primary language `Portuguese (Brazil)`. App Store Connect does not permit creating the app record through its public API.
