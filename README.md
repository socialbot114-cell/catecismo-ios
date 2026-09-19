# Catecismo da Igreja Católica

Aplicativo Android offline-first em Kotlin + Jetpack Compose. `applicationId`: `br.com.CATECISMO.DAIGREJACAToLICA`. Versão 1.0.0 (versionCode 1).

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

O pacote Play Console é `br.com.CATECISMO.DAIGREJACAToLICA`. O release usa a chave local configurada em `keystore.properties`.
