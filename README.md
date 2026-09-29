# Catecismo da Igreja Católica

Aplicativo Android (Kotlin + Jetpack Compose) e iOS (SwiftUI). O ciclo atual prepara somente o release iOS 1.2.1; o Android mantém seu versionamento separado. `applicationId` / bundle ID: `br.com.CATECISMO.DAIGREJACAToLICA`.

## Conteúdo

- Texto em português do Catecismo, organizado em quatro partes e embarcado para leitura offline. A transcrição da edição no PDF da Diocese de Miracema inclui §§1–2865, inclusive §§2217 e 2439; veja `DATA_SOURCES.md`.
- Oito guias autorais ampliados (seis capítulos cada) sobre fé, Credo, sacramentos, vida cristã, oração, Igreja e Maria.
- Leitura paginada por seções, busca local integral (FTS), favoritos, citações e progresso.
- Narração local por TextToSpeech no Android e AVSpeechSynthesizer no iOS, sem dependência de rede.

## Build local

```bash
./gradlew testDebugUnitTest lintDebug assembleDebug bundleRelease
jarsigner -verify -verbose -certs app/build/outputs/bundle/release/app-release.aab
```

O pacote Play Console e o bundle App Store são `br.com.CATECISMO.DAIGREJACAToLICA`. A redistribuição do texto © Libreria Editrice Vaticana deve ter autorização confirmada antes de uma publicação na loja.
