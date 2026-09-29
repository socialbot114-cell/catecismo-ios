# Fontes, atribuição e cobertura

## Texto do Catecismo em português

- Fonte: [Catecismo da Igreja Católica — PDF da Diocese de Miracema](https://diocesedemiracemato.org.br/upload/arquivos/214.pdf), documento de 375 páginas com camada de texto.
- Os assets embarcados foram transcritos dessa edição em português, mantendo a redação e numeração dos §§1–2865, inclusive §§2217 e 2439. Não dependem de acesso à rede para leitura.
- O texto do Catecismo tem origem na publicação da Libreria Editrice Vaticana. A atribuição da fonte é registrada nos assets; o responsável pelo projeto confirmou que a autorização formal para redistribuição integral está obtida.
- O PDF não é necessário no app instalado. Para regenerar os JSONs, use `python3 tools/fetch_catecismo.py /caminho/para/214.pdf`; o script requer `pdftotext` (Poppler).

## Guias autorais

- Oito guias da Equipe Catecismo. Cada guia preserva seus capítulos iniciais e adiciona quatro seções autorais com referências ao Catecismo.
- As referências (§N) servem para localizar temas no texto embarcado; os guias não são texto magisterial.
- Fonte editável: `tools/guides_content.json`; compilação/cópia para Android e iOS: `tools/build_guides.py`.

## Validação

- `tools/validate_assets.py`: valida assets Android, capítulos e cobertura integral dos 2.865 parágrafos numerados.
- `tools/validate_ios_assets.py`: valida os 12 recursos do pacote iOS.
- Estatísticas geradas: `RELATORIO_CONTEUDO.md`.
