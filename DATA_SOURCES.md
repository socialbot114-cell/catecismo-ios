# Fontes e direitos do conteúdo

## Catecismo da Igreja Católica — texto integral embarcado

- Texto: edição oficial em português publicada pelo Vaticano em `vatican.va/archive/cathechism_po/` (§§1–2865).
- Copyright: © Libreria Editrice Vaticana. O app distribui o texto integral de forma gratuita, sem alteração de conteúdo, com atribuição na tela "Fonte" de cada parte e na seção "Sobre".
- Os §§2217 e 2439 não constam na página em português do Vaticano; nenhum outro texto foi tecido no lugar deles, por fidelidade à fonte oficial.
- Pipeline reproduzível: `tools/fetch_catecismo.py` (cache em `tools/cache/catecismo/`, apenas ambiente de desenvolvimento).

## Guias autorais (8 obras)

- Conteúdo próprio da Equipe Catecismo, referenciando §§ oficiais do Catecismo para navegação cruzada.
- Estrutura: 6 seções por guia, com propostas práticas de aprofundamento semanal.

## Documentação

- `RELATORIO_CONTEUDO.md`: estatísticas geradas por `tools/validate_assets.py`.
- `tools/validate_ios_assets.py`: consistência do pacote iOS (12 obras).

## Publicação

- Play Console: pacote `br.com.CATECISMO.DAIGREJACAToLICA`.
- App Store Connect: bundle `br.com.CATECISMO.DAIGREJACAToLICA` (iOS 1.2.1).
