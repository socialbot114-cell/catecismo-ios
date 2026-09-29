# Catecismo da Igreja Católica

Aplicativo Android (Kotlin + Jetpack Compose) e iOS (SwiftUI). `applicationId`: `br.com.CATECISMO.DAIGREJACAToLICA`. Versão Android 1.1.0 (versionCode 3); iOS 1.2.1.

## Conteúdo

- **Texto integral do Catecismo da Igreja Católica (§§1–2865)** em quatro partes, fonte vatican.va (© Libreria Editrice Vaticana), com leitura offline, busca e narração.
- Oito guias autorais expandidos (6 seções, ~550-1000 palavras cada) sobre fé, Credo, sacramentos, vida cristã, oração, Igreja e Maria.
- Leitura paginada por seções, busca local integral (FTS), favoritos, citações e progresso.
- Narração local por TextToSpeech no Android e AVSpeechSynthesizer no iOS, sem dependência de rede.

## Build local

```bash
./gradlew testDebugUnitTest lintDebug assembleDebug bundleRelease
jarsigner -verify -verbose -certs app/build/outputs/bundle/release/app-release.aab
```

O pacote Play Console é `br.com.CATECISMO.DAIGREJACAToLICA`. O release usa a chave local configurada em `keystore.properties`.
