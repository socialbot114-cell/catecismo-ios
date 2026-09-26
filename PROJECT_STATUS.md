# Catecismo — Estado do Projeto

Última atualização: 2026-09-26

## Identidade

- App Store Connect app ID: `6813681189`
- SKU: `Catecismo-da-Igreja-Catolica`
- Bundle ID: `br.com.CATECISMO.DAIGREJACAToLICA`
- Versão iOS em preparação: `1.1`
- Próximo build iOS: `14` (run number seguinte ao último workflow de release `13`)
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
- O workflow de release TestFlight é manual; nenhum envio para revisão da App Store é automático.

## Próxima release

Preparar e validar iOS `1.1` antes de qualquer upload. O número de build é definido pelo workflow de release. Confirmar no App Store Connect que o app ID e o SKU acima correspondem ao registro correto antes de enviar.
