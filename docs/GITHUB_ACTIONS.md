# GitHub Actions

The normal Android workflow runs content validation, shared JVM tests, Android unit tests, lint, and a debug build on every push and pull request.

The release workflow is manual. Configure these encrypted repository secrets before using it:

- `ANDROID_KEYSTORE_BASE64`: base64 of `machado-release.keystore`
- `ANDROID_KEYSTORE_PASSWORD`: current PKCS12 password
- `ANDROID_KEY_PASSWORD`: current PKCS12 key password

The iOS workflow is also manual. It currently builds an unsigned simulator target after generating the project with XcodeGen. Distribution signing and TestFlight upload require Apple Team ID, certificates or automatic signing, and App Store Connect credentials.
