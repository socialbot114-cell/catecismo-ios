# Catecismo iOS App

Independent and unofficial SwiftUI reader for eight authored guides in Portuguese (Brazil), English, Spanish, and French, plus four Portuguese parts transcribed from the Catechism edition in the Diocese of Miracema PDF. The app follows the device language by default and includes a saved language selector. All 2,865 numbered paragraphs (§§1–2865), including §§2217 and 2439, are bundled for offline reading; no external reading links are included. Bundle identifier: `br.com.CATECISMO.DAIGREJACAToLICA`. Planned version: 1.2.2.

The Catechism text is reproduced from the Portuguese edition in the Diocese of Miracema PDF and originates in the publication of the Libreria Editrice Vaticana. Attribution is included with the bundled text; permission to redistribute the full text in an App Store release must be confirmed before release.

```bash
xcodegen generate --spec iosApp/project.yml
xcodebuild -project iosApp/Catecismo.xcodeproj -scheme Catecismo -sdk iphonesimulator build
```

The app is not an official Vatican publication and does not replace ecclesial or pastoral guidance.
