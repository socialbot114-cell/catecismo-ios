# GitHub Actions

The normal Android workflow runs content validation, shared JVM tests, Android unit tests, lint, and a debug build on every push and pull request.

The release workflow is manual. Configure these encrypted repository secrets before using it:

- `ANDROID_KEYSTORE_BASE64`: base64 do arquivo de assinatura Android
- `ANDROID_KEYSTORE_PASSWORD`: current PKCS12 password
- `ANDROID_KEY_PASSWORD`: current PKCS12 key password

The iOS workflow is manual and uses the `macos-26` runner with Xcode 26. The Apple Team ID is `SRN7AW424S`. The `iOS TestFlight` workflow uses automatic signing through the App Store Connect API key and uploads the exported IPA after archiving.

The first app record still must exist in App Store Connect. Create it with bundle ID `br.com.CATECISMO.DAIGREJACAToLICA`, name `Catecismo`, a unique SKU, and primary language `Portuguese (Brazil)`. App Store Connect does not permit creating the app record through its public API.
