# Catecismo — status do projeto

## Versão em preparação

- iOS: 1.2.1 (build 31) submitted to App Review; automatic release is configured after approval. The previous production version was 1.1.1 (build 30).
- Bundle ID: `br.com.CATECISMO.DAIGREJACAToLICA`.
- O escopo de publicação desta revisão é iOS. O versionamento Android permanece separado.

## Conteúdo local

- Oito guias autorais, preservando os capítulos originais e acrescentando quatro seções revisadas por guia.
- Quatro assets do Catecismo em português, transcritos do PDF da Diocese de Miracema, com §§1–2865 e leitura offline.
- §§2217 e 2439 estão presentes nos assets, copiados da mesma edição em português do PDF.
- O texto é atribuído à Libreria Editrice Vaticana. Atribuição está no app; o responsável pelo projeto confirmou que a autorização formal para redistribuição integral está obtida.
- A interface permanece disponível em português, inglês, espanhol e francês. O texto oficial embarcado é a edição em português.

## Validação e evidências

- `python3 tools/validate_assets.py`: assets Android e conteúdo do catálogo.
- `python3 tools/validate_ios_assets.py`: recursos, catálogo e arquivos empacotados do iOS.
- `./gradlew testDebugUnitTest lintDebug`: testes/lint Android.
- `.github/workflows/ios-screenshots.yml`: capturas de auditoria em simuladores iPhone e iPad.
- `.github/workflows/ios-release.yml`: build IPA, atualização dos URLs em português no App Store Connect e submissão opcional para App Review com lançamento automático após aprovação.
- `.github/workflows/pages.yml`: publicação das páginas de suporte e privacidade via GitHub Pages.

## Pipelines

- `python3 tools/fetch_catecismo.py /caminho/para/214.pdf`: extrai os 2.865 parágrafos do PDF e gera os quatro assets locais. Requer `pdftotext` (Poppler).
- `python3 tools/build_guides.py`: combina os guias-base preservados com as expansões revisadas e atualiza os catálogos.
- O PDF-fonte é insumo de manutenção e não é dependência do aplicativo instalado.
