# iOS App

The iOS target is SwiftUI with bundle identifier `br.com.machadodeassis.biblioteca.ios`. The original universal identifier is retained for compatibility with the existing registration; the dedicated iOS identifier is used for App Store distribution.

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
xcodegen generate --spec iosApp/project.yml
xcodebuild -project MachadoBiblioteca.xcodeproj -scheme MachadoBiblioteca -sdk iphonesimulator build
```

The project targets iOS 17 and is built for App Store submissions with Xcode 26 on the `macos-26` GitHub runner. The source bundles the 30 offline catalog entries, full text JSON resources, AI-created visual assets, and local Brazilian Portuguese speech. Persistence and advanced lock-screen controls remain follow-up work before public review.
