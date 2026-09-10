# iOS App

The iOS target is SwiftUI with bundle identifier `br.com.machadodeassis.biblioteca`.

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
xcodegen generate --spec iosApp/project.yml
xcodebuild -project MachadoBiblioteca.xcodeproj -scheme MachadoBiblioteca -sdk iphonesimulator build
```

The current source is the first native shell. Content loading, local persistence, KMP framework integration, lock-screen controls, and TestFlight signing require a macOS runner.
