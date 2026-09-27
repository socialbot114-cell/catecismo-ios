# Fontes de conteúdo — Catecismo

## Conteúdo do aplicativo

O aplicativo oferece oito guias autorais de introdução e reflexão, organizados em dezesseis capítulos e disponíveis em português do Brasil, inglês, espanhol e francês. As traduções mantêm os mesmos IDs, capítulos e ordem dos parágrafos; devem passar por revisão editorial e não reproduzem integralmente o Catecismo da Igreja Católica.

As referências temáticas apontam para edições oficiais do Catecismo da Igreja Católica:

- Catecismo da Igreja Católica (Santa Sé): <https://www.vatican.va/archive/cathechism_po/index_new/prima-pagina-cic_po.html>
- Inglês: <https://www.vatican.va/archive/ENG0015/_INDEX.HTM>
- Espanhol: <https://www.vatican.va/archive/catechism_sp/index_sp.html>
- Francês: <https://www.vatican.va/archive/FRA0013/_INDEX.HTM>

## Seção de fontes — Catecismo de São Pio X

A seção “São Pio X” nos aplicativos oferece links externos para consulta; essas edições não são baixadas nem reproduzidas nos arquivos offline do app.

- Português: MONTFORT, “Catecismo de São Pio X” — <https://www.montfort.org.br/bra/documentos/catecismo/catecismo_s_pio_x/>; fac-símile do Internet Archive — <https://archive.org/details/catecismo-maior-de-sc3a3o-pio-x>. A edição digital do Archive indica tradução não oficial e atualizações de 1976.
- Italiano: Wikisource, “Compendio della dottrina cristiana / Catechismo maggiore” — <https://it.wikisource.org/wiki/Compendio_della_dottrina_cristiana/Catechismo_maggiore>, transcrição da edição romana de 1905.
- Inglês: Internet Archive, “The Catechism of Pope Saint Pius X” (1911) — <https://archive.org/details/catechism-of-pope-saint-pius-x>. A descrição identifica uma versão anterior de Mântua, do período em que Pio X era bispo, não a edição romana de 1905.
- Espanhol: Internet Archive, “Catecismo Mayor de San Pío X” (1906) — <https://archive.org/details/catecismo-mayor-de-san-pio-x-1906>. O exemplar digitalizado contém uma reserva editorial sobre reprodução.
- Francês: tradução completa da edição romana (1905/1906) — <https://archive.org/details/catechisme-de-rome-de-st-pie-x-1905>; edição abreviada de 1912 — <https://archive.org/details/catechisme-de-rome-de-saint-pie-x-1912>. A transcrição digital de 1912 informa 433 perguntas e direitos de reutilização não comercial; a versão completa é descrita com 993 perguntas.

O texto original italiano de 1905 é de domínio público. A situação jurídica de cada tradução e transcrição é independente. Os candidatos em francês, espanhol e inglês permanecem como links externos: a edição espanhola contém uma reserva de reprodução, o arquivo digital francês de 1912 limita a reutilização a fins não comerciais, e o inglês de 1911 é uma versão anterior de Mântua, não a edição romana de 1905. Uma nova tradução inglesa do texto italiano precisa de revisão editorial e créditos definidos antes de ser empacotada offline.

## Arquivos embarcados

- Android: `app/src/main/assets/texts/`
- iOS: `iosApp/Resources/Texts/`
- Traduções dos guias para validação: `app/src/main/assets/texts/locales/`
- Catálogo de interface iOS: `iosApp/Resources/Localizable.xcstrings`
- Catálogo iOS: `iosApp/Resources/catalog.json`
- Relatório validado: `RELATORIO_CONTEUDO.md`

Os guias são empacotados para leitura offline. Alterações de conteúdo devem preservar IDs e estrutura entre idiomas, revisar as referências e executar `python3 tools/validate_assets.py` e `python3 tools/validate_ios_assets.py`.
