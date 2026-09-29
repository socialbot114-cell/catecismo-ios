# Catecismo — status do projeto

## Versão em preparação

- iOS: 1.2.1; próximo build planejado: 31. A referência de produção anterior é 1.1.1 (build 30).
- Bundle ID: `br.com.CATECISMO.DAIGREJACAToLICA`.
- O escopo de publicação desta revisão é iOS. O versionamento Android permanece separado.

## Conteúdo local

- Oito guias autorais, preservando os capítulos originais e acrescentando quatro seções revisadas por guia.
- Quatro assets do Catecismo em português, com numeração de parágrafos e leitura offline.
- A página em português do Vatican.va consultada não apresenta §§2217 e 2439; os parágrafos não foram preenchidos por outra tradução.
- O texto é © Libreria Editrice Vaticana. Atribuição está no app; autorização de redistribuição precisa estar confirmada antes da publicação na loja.
- A interface permanece disponível em português, inglês, espanhol e francês. O texto oficial embarcado é a edição em português.

## Validação e evidências

- `python3 tools/validate_assets.py`: assets Android e conteúdo do catálogo.
- `python3 tools/validate_ios_assets.py`: recursos, catálogo e arquivos empacotados do iOS.
- `./gradlew testDebugUnitTest lintDebug`: testes/lint Android.
- `.github/workflows/ios-screenshots.yml`: capturas de auditoria em simuladores iPhone e iPad.
- `.github/workflows/ios-release.yml`: build IPA e envio TestFlight; executar somente após aprovar as evidências e confirmar autorização de conteúdo.

## Pipelines

- `python3 tools/fetch_catecismo.py`: obtém/cacheia as páginas oficiais e gera quatro assets locais.
- `python3 tools/build_guides.py`: combina os guias-base preservados com as expansões revisadas e atualiza os catálogos.
- `tools/cache/` contém cache local de desenvolvimento e não é dependência do aplicativo.
