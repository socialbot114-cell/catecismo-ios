# Release Checklist

## Before release

- [ ] Confirm all image licenses in `ASSET_LICENSES.md`.
- [ ] Rotate any credential exposed outside the local machine.
- [ ] Run `python3 tools/validate_assets.py`.
- [ ] Run Android unit tests and lint.
- [ ] Test Room migration and TTS on a real Android device.
- [ ] Generate the iOS project with XcodeGen on macOS.
- [ ] Test VoiceOver, Dynamic Type, Dark Mode, background audio, and locked-screen controls.
- [ ] Confirm `br.com.machadodeassis.biblioteca` in both stores.

## Android

- [ ] Configure `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, and `ANDROID_KEY_PASSWORD` in CI.
- [ ] Build and verify the signed AAB.
- [ ] Upload to Play Console internal testing.

## iOS

- [ ] Configure `APPLE_TEAM_ID` and App Store Connect API credentials in CI.
- [ ] Build and archive on a macOS runner.
- [ ] Upload to TestFlight internal testing.

## Store listing

- [ ] Publish privacy policy and support URLs.
- [ ] Document that no account, tracking, ads, or server sync are used.
- [ ] Add source and attribution notes.
