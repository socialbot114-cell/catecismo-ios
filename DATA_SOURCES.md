# Fontes de conteúdo — Catecismo

## Conteúdo do aplicativo

O aplicativo oferece oito guias autorais de introdução e reflexão, organizados em dezesseis capítulos. Os textos são identificados como produzidos pela Equipe Catecismo e não reproduzem integralmente o Catecismo da Igreja Católica nem substituem as fontes oficiais.

Os guias apontam para a versão em português do Catecismo publicada pela Santa Sé como referência temática:

- Catecismo da Igreja Católica (Santa Sé): <https://www.vatican.va/archive/cathechism_po/index_new/prima-pagina-cic_po.html>

## Arquivos embarcados

- Android: `app/src/main/assets/texts/`
- iOS: `iosApp/Resources/Texts/`
- Catálogo iOS: `iosApp/Resources/catalog.json`
- Relatório validado: `RELATORIO_CONTEUDO.md`

Os arquivos são empacotados para leitura offline. Alterações de conteúdo devem preservar o caráter autoral dos guias, revisar as referências e executar `python3 tools/validate_assets.py`.
