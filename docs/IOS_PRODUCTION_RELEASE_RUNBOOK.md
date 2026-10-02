# Runbook de release iOS — Catecismo

Passo a passo para obter o projeto, validar conteúdo e interface, revisar screenshots e publicar uma versão iOS na App Store. As instruções refletem o fluxo usado para a versão **1.2.1 (build 31)**.

## Estado desta execução

- Build `1.2.1 (31)` processado no App Store Connect.
- Versão submetida à App Review; o lançamento automático está configurado para depois da aprovação da Apple.
- A decisão da Apple ainda está pendente.
- Páginas públicas:
  - Site: <https://socialbot114-cell.github.io/catecismo-ios/>
  - Privacidade: <https://socialbot114-cell.github.io/catecismo-ios/privacy.html>
  - Suporte: <https://socialbot114-cell.github.io/catecismo-ios/support.html>

## Identificadores e referências

| Item | Valor |
|---|---|
| Repositório | `socialbot114-cell/catecismo-ios` |
| Branch de integração/publicação | `main` |
| Bundle ID | `br.com.CATECISMO.DAIGREJACAToLICA` |
| App Store Connect app ID | `6813681189` |
| Versão iOS desta release | `1.2.1` |
| Build desta release | `31` |
| Workflow de release | `.github/workflows/ios-release.yml` |
| Workflow de submissão de build processado | `.github/workflows/ios-submit.yml` |

O pacote inclui 12 obras: quatro partes do Catecismo e oito guias autorais, com §§1–2865. Estatísticas: 114 seções e 217.769 palavras (`RELATORIO_CONTEUDO.md`).

## 1. Obter a versão atual do projeto

Clone o repositório ou atualize o clone existente para `main`:

```bash
gh repo clone socialbot114-cell/catecismo-ios
cd catecismo-ios
git checkout main
git pull --ff-only origin main
git status --short --branch
```

Antes de release, confirme que a branch usada pelos workflows contém as alterações revisadas. O ambiente `github-pages` exige publicação a partir de `main`.

## 2. Conferir fontes e direitos de distribuição

Antes de empacotar conteúdo, confirmar com o responsável pelo projeto os direitos para uso e distribuição comercial de:

- Texto integral do Catecismo em português.
- Ícones, ilustrações e fundos incluídos nos aplicativos.
- Guias autorais e demais textos.

Registrar as fontes e confirmações em `DATA_SOURCES.md` e `ASSET_LICENSES.md`. Para a versão 1.2.1, o responsável confirmou formalmente a autorização do texto e os direitos das artes.

## 3. Validar catálogo, conteúdo e Android

Na raiz do repositório:

```bash
python3 tools/validate_assets.py
python3 tools/validate_ios_assets.py
./gradlew testDebugUnitTest lintDebug :shared:jvmTest --console=plain
```

As validações confirmam o catálogo Android/iOS, as 12 obras locais e a cobertura dos parágrafos do Catecismo. O workflow `Android` repete os validadores, testes, lint e build de debug no GitHub Actions.

## 4. Testar o app iOS

O workflow `Catecismo iOS CI` (`.github/workflows/ios.yml`) valida os recursos e executa XCTest em um simulador iPhone instalado. O nome/UDID do simulador é descoberto em tempo de execução por `tools/select_ios_simulator.py`, evitando depender de um modelo que não esteja disponível naquela imagem do runner.

Para executar manualmente:

```bash
gh workflow run ios.yml --repo socialbot114-cell/catecismo-ios --ref main
gh run list --repo socialbot114-cell/catecismo-ios --workflow ios.yml --limit 5
```

Abra o run retornado e aguarde os jobs `validate` e `build` concluírem com sucesso. Se o código-fonte do app mudar depois dos testes, execute-os novamente antes de usar a opção `previous_tests_passed` no release.

## 5. Capturar e revisar screenshots

Execute o workflow `Catecismo iOS Screenshots (auditoria 1.2.1)`:

```bash
gh workflow run ios-screenshots.yml --repo socialbot114-cell/catecismo-ios --ref main
gh run list --repo socialbot114-cell/catecismo-ios --workflow ios-screenshots.yml --limit 5
```

O workflow captura iPhone e iPad. Em cada dispositivo, revise os quatro idiomas (português, inglês, espanhol e francês), as telas de início, biblioteca, leitor, busca e temas, além dos estados de rolagem/navegação. Nesta auditoria foram geradas 56 imagens por dispositivo (14 estados × 4 idiomas).

Baixe os artifacts do run escolhido:

```bash
RUN_ID=36609714050 # substitua pelo ID do run atual
gh run download "$RUN_ID" --repo socialbot114-cell/catecismo-ios --dir "prints/audit-1.2.1-$RUN_ID"
```

Na execução registrada, as folhas de contato finais ficaram em:

- `prints/audit-1.2.1-final-36609714050/contact-sheets/iphone-all-locales.jpg`
- `prints/audit-1.2.1-final-36609714050/contact-sheets/ipad-all-locales.jpg`

As capturas de auditoria são evidência de QA; não são enviadas automaticamente como screenshots promocionais da App Store. O release workflow usa `--skip_screenshots`, preservando as imagens já configuradas na listagem.

## 6. Publicar privacidade e suporte

Revise os arquivos estáticos:

- `site/index.html`
- `site/privacy.html`
- `site/support.html`

O workflow `Publish project website` (`.github/workflows/pages.yml`) publica `site/` no GitHub Pages. Uma alteração em `site/` em `main` inicia o deploy automaticamente; também é possível disparar manualmente:

```bash
gh workflow run pages.yml --repo socialbot114-cell/catecismo-ios --ref main
```

Verifique as páginas públicas após o workflow terminar:

```bash
curl --fail --silent --show-error --head https://socialbot114-cell.github.io/catecismo-ios/privacy.html
curl --fail --silent --show-error --head https://socialbot114-cell.github.io/catecismo-ios/support.html
```

O ambiente GitHub Pages tem proteção que só aceita deploy a partir de `main`; deploy iniciado em branch de trabalho pode falhar antes dos passos do workflow.

## 7. Configurar URLs e novidades no App Store Connect

Os metadados localizados em português brasileiro ficam em `store-kit/metadata/pt-BR/`:

- `privacy_url.txt`
- `support_url.txt`
- `release_notes.txt` — obrigatório para a submissão; corresponde ao campo “Novidades desta versão” (`whatsNew`).

Antes do upload, edite `release_notes.txt` com as novidades reais da versão. Para preparar o rascunho 1.2.1 e gravar nele os links públicos de privacidade e suporte:

```bash
gh workflow run store-urls.yml --repo socialbot114-cell/catecismo-ios --ref main \
  -f confirm_store_url_update=true
```

O workflow usa App Store Connect API/Spaceship, cria ou confirma o rascunho 1.2.1 e atualiza o `AppInfo` e a localização da versão em preparação. A política de privacidade da versão já publicada pode ficar imutável enquanto está em `Ready for Distribution`; atualize o rascunho da nova versão em vez de tentar editar diretamente a versão pública.

## 8. Preparar build e envio à App Store

### Versão/build

Para 1.2.1, os valores `1.2.1` e `31` são intencionalmente explícitos em:

- `iosApp/Info.plist`
- `iosApp/project.yml` — `MARKETING_VERSION`, `CURRENT_PROJECT_VERSION` e propriedades de `info` do XcodeGen.
- `.github/workflows/ios-release.yml` — arquivo, export e verificações do IPA.

Ao criar uma versão futura, atualize esses valores juntos e confirme-os no archive **e no IPA exportado**. A exportação precisa manter o número recebido do archive (`manageAppVersionAndBuildNumber: false`).

### Secrets necessários

O repositório precisa ter estes secrets de Actions configurados; nunca coloque seus valores no código ou neste documento:

- `APPLE_API_KEY_P8`
- `APPLE_API_KEY_ID`
- `APPLE_API_ISSUER_ID`
- `APPLE_DISTRIBUTION_CERT`
- `APPLE_DISTRIBUTION_KEY`
- `APPLE_PROVISIONING_PROFILE`

### Build e upload

O workflow `Catecismo iOS App Store` usa `macos-26` para compilar com SDK iOS 26. A Apple rejeitou o primeiro IPA feito pelo runner `macos-15` porque ele continha o SDK iOS 18.5; para distribuição, use o runner Xcode 26 ou mais recente.

Para fazer testes XCTest e carregar o IPA sem submetê-lo ainda:

```bash
gh workflow run ios-release.yml --repo socialbot114-cell/catecismo-ios --ref main \
  -f confirm_app_store_submission=false \
  -f previous_tests_passed=false
gh run list --repo socialbot114-cell/catecismo-ios --workflow ios-release.yml --limit 5
```

Espere o build ser carregado e processado pelo App Store Connect antes da etapa seguinte. Use `previous_tests_passed=true` somente quando o mesmo código do app já tiver passado no XCTest; caso contrário, mantenha `false`.

### Submeter um build já processado

Se o build já foi enviado/processado — ou se uma tentativa falhou depois do upload — use o workflow sem reconstruir e sem reenviar o IPA:

```bash
gh workflow run ios-submit.yml --repo socialbot114-cell/catecismo-ios --ref main \
  -f confirm_app_review_submission=true \
  -f build_number=31
```

Esse workflow atualiza a localização com `release_notes.txt`, seleciona o build existente, submete à App Review e define `automatic_release=true`. No log, confirme `Successfully submitted the app for review!` e os valores `submit_for_review=true` e `automatic_release=true`.

Também é possível usar `confirm_app_store_submission=true` no workflow de release para carregar e submeter na mesma execução. O fluxo em duas etapas é preferível quando o build já está processado: evita reenviar um número de build existente se a submissão de metadados precisar de correção.

## 9. Acompanhar aprovação e lançamento

Para acompanhar as execuções do release e da submissão:

```bash
gh run list --repo socialbot114-cell/catecismo-ios --workflow ios-release.yml --limit 5
gh run list --repo socialbot114-cell/catecismo-ios --workflow ios-submit.yml --limit 5
```

Depois da submissão, acompanhe o estado da versão no App Store Connect. A etapa do agente termina quando a Apple aceita a submissão; a revisão e a decisão final são da Apple. Com `automatic_release=true`, a versão será liberada automaticamente depois da aprovação.

## Problemas encontrados e soluções

- **SDK de iOS antigo:** se o uploader reportar que o IPA usou SDK 18.5, use `macos-26`/Xcode 26+ no workflow de release.
- **IPA com versão `1.0 (1)`:** mantenha `CFBundleShortVersionString` e `CFBundleVersion` explícitos no `Info.plist` e nas propriedades de `info` do XcodeGen; valide os valores no archive e no IPA depois de `xcodebuild -exportArchive`.
- **`whatsNew` ausente:** crie/preencha `store-kit/metadata/pt-BR/release_notes.txt` antes de submeter. Se o IPA já foi processado, execute `ios-submit.yml` para reutilizar o build.
- **URL de privacidade bloqueada no estado público:** a localização da versão publicada pode não aceitar edição. Atualize o `AppInfo` do rascunho 1.2.1 com `store-urls.yml`; o novo link passa à listagem com o lançamento da versão.
- **Simulador nomeado não encontrado:** use `tools/select_ios_simulator.py` e o UDID de um simulador instalado, como fazem os workflows iOS.
- **Deploy Pages falha sem iniciar passos:** confira que o run está em `main`, pois o ambiente `github-pages` é protegido por política de branch.

## Runs desta execução

- 1.2.2 (32): CI `36935738294` e `36939562037` — sucesso; release com XCTest, upload e submissão à App Review com lançamento automático: `36942565155` — sucesso.

### 1.2.1

- Auditoria final de screenshots iPhone/iPad: `36609714050` — sucesso.
- Deploy público do site: `36635197062` — sucesso.
- URLs do App Store Connect: `36639190537` — sucesso.
- Build 1.2.1 (31): processado no App Store Connect.
- Submissão à App Review, com lançamento automático: `36648026834` — sucesso.
