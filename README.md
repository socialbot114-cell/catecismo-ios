# Catecismo da Igreja Católica

Aplicativo offline-first para Android (Kotlin + Jetpack Compose) e iOS (SwiftUI). Bundle ID: `br.com.CATECISMO.DAIGREJACAToLICA`. A próxima versão iOS em preparação é `1.1`; o Android permanece em `1.0.0` (versionCode 2) até uma release própria.

## Conteúdo

- Oito guias autorais sobre fé, Credo, sacramentos, vida cristã, oração, Igreja e Maria.
- Leitura paginada por capítulos, busca local, favoritos, citações e progresso.
- Narração local por TextToSpeech, sem dependência de rede.
- Textos inspirados na organização do Catecismo e em referências oficiais; não redistribui o texto integral de terceiros.

## Build local

```bash
./gradlew testDebugUnitTest lintDebug assembleDebug bundleRelease
jarsigner -verify -verbose -certs app/build/outputs/bundle/release/app-release.aab
```

O pacote Play Console e o Bundle ID iOS são `br.com.CATECISMO.DAIGREJACAToLICA`. Releases Android exigem uma assinatura exclusiva do Catecismo em `keystore.properties` e nos secrets `CATECISMO_ANDROID_*`; a release iOS é independente.
