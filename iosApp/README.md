# Catecismo iOS App

Independent and unofficial SwiftUI reader for eight bundled Catecismo introduction guides in Portuguese (Brazilian), English, Spanish, and French. The app follows the device language by default and includes a saved in-app language selector. São Pio X editions are linked externally while translation and transcription reuse rights are reviewed. Bundle identifier: `br.com.CATECISMO.DAIGREJACAToLICA`.

```bash
xcodegen generate --spec iosApp/project.yml
xcodebuild -project iosApp/Catecismo.xcodeproj -scheme Catecismo -sdk iphonesimulator build
```

The app does not claim to be the official or complete Catechism and does not replace official sources.
