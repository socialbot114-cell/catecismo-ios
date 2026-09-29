# Catecismo iOS App

Independent and unofficial SwiftUI reader for eight authored guides in Portuguese (Brazil), English, Spanish, and French, plus four Portuguese parts from the Catechism text published at Vatican.va. The app follows the device language by default and includes a saved language selector. The Catechism pages in Portuguese consulted omit §§2217 and 2439. No Internet Archive, PDF, or other external reading links are included in this release. Bundle identifier: `br.com.CATECISMO.DAIGREJACAToLICA`. Planned version: 1.2.1.

The Vatican text is © Libreria Editrice Vaticana. Attribution is included in the app; permission to redistribute the text in an App Store release must be confirmed before release.

```bash
xcodegen generate --spec iosApp/project.yml
xcodebuild -project iosApp/Catecismo.xcodeproj -scheme Catecismo -sdk iphonesimulator build
```

The app is not an official Vatican publication and does not replace ecclesial or pastoral guidance.
