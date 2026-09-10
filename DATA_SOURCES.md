# Fontes e domínio público

As obras do catálogo foram publicadas por Machado de Assis entre 1870 e 1908. No Brasil, a proteção patrimonial expira 70 anos após a morte do autor; Machado faleceu em 1908. Portanto, os textos originais estão em domínio público.

## Textos embarcados

Os textos integrais desta versão (v1.2.0) foram obtidos por transcrição automatizada do Wikisource em português, por meio da API MediaWiki (`action=parse`), com pipeline reproduzível em `tools/fetch_machado.py`:

- Autor no Wikisource PT: https://pt.wikisource.org/wiki/Autor:Machado_de_Assis
- Cada obra registra sua página de origem no campo `sourceUrl` do asset JSON (ex.: `https://pt.wikisource.org/wiki/Dom_Casmurro`).
- Licença das transcrições: Creative Commons Attribution-ShareAlike (CC BY-SA), dos colaboradores do Wikisource. A atribuição a cada página é preservada via `sourceUrl`.
- Texto original de Machado de Assis: domínio público (falecido em 1908).

## Adaptação ortográfica

Aplicamos modernização ortográfica conservadora e declarada (ex.: `idéia → ideia`, `herva → erva`, trema removido), sem alterar sintaxe ou vocabulário. A lista completa de substituições está em `tools/fetch_machado.py` (`MODERN`).

## Referências de metadados

- Catálogo e edições de conferência: Biblioteca Brasiliana Guita e José Mindlin, USP: https://digital.bbm.usp.br/
- Obras e metadados: Projeto Gutenberg: https://www.gutenberg.org/ebooks/author/1586
- Datas biográficas: Academia Brasileira de Letras: https://www.academia.org.br/academicos/machado-de-assis/biografia

## Escopo

Esta versão embarca 30 obras integrais (10 romances e 20 contos) para leitura offline. Nenhum conteúdo contemporâneo protegido foi usado como texto literário; traduções, edições críticas, notas e capas de terceiros podem ter direitos próprios e não foram embarcadas.

## Reprodução

```bash
python3 tools/fetch_machado.py      # baixa e gera app/src/main/assets/texts/*.json.gzdata
python3 tools/validate_assets.py    # valida e gera RELATORIO_CONTEUDO.md
```
