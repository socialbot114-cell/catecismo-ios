# Catecismo — Estado do Projeto

Última atualização: 2026-09-27

## Identidade

- App Store Connect app ID: `6813681189`
- SKU: `Catecismo-da-Igreja-Catolica`
- Bundle ID: `br.com.CATECISMO.DAIGREJACAToLICA`
- Última versão enviada: `1.1 (17)` (workflow run `36257985758`, Delivery UUID `5dbccf9e-02d0-44be-bd9b-4c70c8a7fc75`)
- Versão iOS em preparação: `1.1.1`
- Build planejado: `27` (o workflow define o build number pelo número da execução)
- Repositório: `socialbot114-cell/catecismo-ios`

## Aplicativo

- App iOS nativo em SwiftUI, com mínimo iOS 17.
- App Android nativo em Kotlin/Compose.
- Oito guias autorais, dezesseis capítulos e leitura offline.
- Recursos iOS: busca, temas, favoritos, citações, progresso e narração local.
- Os apps e seus materiais de release são mantidos separados do projeto Biblioteca Machado de Assis.

## Arte e recursos

- Originais visuais fornecidos para o projeto: `COMPONENTS/`.
- Ícone iOS: conjunto `iosApp/Resources/Assets.xcassets/AppIcon.appiconset/`.
- Recursos visuais otimizados usados pelo app: `iosApp/Resources/Images/`.
- Prints de referência anteriores: `store-kit/screenshots/`.
- Prints iOS 1.1 do GitHub Actions, prontos para avaliação: `store-kit/review/ios-1.1/`.

## Validação e capturas

- Workflow de validação iOS: `.github/workflows/ios.yml`.
- Workflow de capturas iPhone/iPad: `.github/workflows/ios-screenshots.yml`.
- Workflow final de capturas iPhone/iPad: run `36253423956` (sucesso; cinco telas por dispositivo).
- Workflow de release iOS: run `36257985758` (upload aceito; processamento no App Store Connect não confirmado aqui).
- O workflow de release TestFlight é manual; nenhum envio para revisão da App Store é automático.

## Próxima release

Validar e enviar iOS `1.1.1` ao TestFlight pelo workflow manual `.github/workflows/ios-release.yml`. O próximo número de execução esperado é build `27` após as falhas nos runs `18` a `26`. Confirmar no App Store Connect que o app ID e o SKU acima correspondem ao registro correto.
