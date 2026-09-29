# Release Checklist

## Before release

- [x] Confirm app icon and packaged artwork distribution rights with the project owner; recorded in `ASSET_LICENSES.md`.
- [x] Confirm Catechism text redistribution authorization with the project owner.
- [ ] Rotate any credential exposed outside the local machine.
- [ ] Run `python3 tools/validate_assets.py`.
- [ ] Run Android unit tests and lint.
- [ ] Test Room migration and TTS on a real Android device.
- [ ] Generate the iOS project with XcodeGen on macOS.
- [ ] Test VoiceOver, Dynamic Type, Dark Mode, background audio, and locked-screen controls.
- [ ] Confirm `br.com.CATECISMO.DAIGREJACAToLICA` in both stores.

## Android

- [ ] Configure `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, and `ANDROID_KEY_PASSWORD` in CI.
- [ ] Build and verify the signed AAB.
- [ ] Upload to Play Console internal testing.

## iOS

- [x] Configure App Store Connect API credentials in GitHub Actions.
- [ ] Build and archive version 1.2.1 (build 31) on a macOS runner.
- [ ] Submit the build to App Review with automatic release after approval.

## Store listing

- [x] Publish privacy policy and support pages at GitHub Pages.
- [ ] Update App Store Connect with the published privacy and support URLs.
- [x] Document that no account, tracking, ads, or server sync are used.
- [x] Add source and attribution notes.
