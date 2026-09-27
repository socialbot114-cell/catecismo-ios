# Catecismo iOS App

Independent and unofficial SwiftUI reader for eight bundled Catecismo introduction guides, with a separate São Pio X section linking to external Portuguese and Italian editions. Bundle identifier: `br.com.CATECISMO.DAIGREJACAToLICA`.

```bash
xcodegen generate --spec iosApp/project.yml
xcodebuild -project iosApp/Catecismo.xcodeproj -scheme Catecismo -sdk iphonesimulator build
```

The app does not claim to be the official or complete Catechism and does not replace official sources.
