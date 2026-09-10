# GitHub Actions

The normal Android workflow runs content validation, shared JVM tests, Android unit tests, lint, and a debug build on every push and pull request.

The release workflow is manual. Configure these encrypted repository secrets before using it:

- `ANDROID_KEYSTORE_BASE64`: base64 of `machado-release.keystore`
- `ANDROID_KEYSTORE_PASSWORD`: current PKCS12 password
- `ANDROID_KEY_PASSWORD`: current PKCS12 key password

The iOS workflow is also manual. It currently builds an unsigned simulator target after generating the project with XcodeGen. The Apple Team ID is `SRN7AW424S`. Distribution signing and TestFlight upload still require certificates or automatic signing, and App Store Connect credentials.
