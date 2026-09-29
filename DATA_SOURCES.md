# Fontes, atribuição e cobertura

## Texto do Catecismo em português

- Fonte consultada: [Catecismo da Igreja Católica, arquivo do Vaticano](https://www.vatican.va/archive/cathechism_po/index_new/prima-pagina-cic_po.html).
- Direitos indicados na fonte: © Libreria Editrice Vaticana. A atribuição é exibida no app; **a atribuição não substitui autorização de redistribuição**. A permissão para incluir o texto integral no aplicativo precisa estar confirmada antes da publicação nas lojas.
- O material embarcado conserva a redação portuguesa disponibilizada pelo Vaticano e a numeração dos parágrafos quando presente.
- **Limitação conhecida da fonte consultada:** as páginas em português usadas pelo importador não incluem os §§2217 e 2439. Não foram preenchidos com texto de outra tradução. A interface e os metadados devem descrever o material como texto publicado na fonte em português, não como transcrição completa sem lacunas.
- `https://www.vatican.va/archive/ccc/index_po.htm` é o índice do Catecismo; as páginas de conteúdo utilizadas pelo importador estão em `https://www.vatican.va/archive/cathechism_po/index_new/`.
- O PDF `https://diocesedemiracemato.org.br/upload/arquivos/214.pdf` foi usado somente para comparar estrutura e numeração. É uma tradução/edição diferente; seu texto não foi misturado nem embarcado.
- Pipeline: `tools/fetch_catecismo.py`; cache de desenvolvimento em `tools/cache/catecismo/` (não é dependência de runtime).

## Guias autorais

- Oito guias da Equipe Catecismo. Cada guia preserva seus capítulos iniciais e adiciona quatro seções autorais com referências ao Catecismo.
- As referências (§N) servem para localizar temas no texto embarcado; os guias não são texto magisterial.
- Fonte editável: `tools/guides_content.json`; compilação/cópia para Android e iOS: `tools/build_guides.py`.

## Validação

- `tools/validate_assets.py`: valida assets Android, capítulos e cobertura dos parágrafos numerados, registrando as duas lacunas conhecidas da fonte.
- `tools/validate_ios_assets.py`: valida os 12 recursos do pacote iOS.
- Estatísticas geradas: `RELATORIO_CONTEUDO.md`.
