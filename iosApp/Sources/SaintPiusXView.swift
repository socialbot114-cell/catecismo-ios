import SwiftUI

struct SaintPiusXView: View {
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let portugueseSource = URL(string: "https://www.montfort.org.br/bra/documentos/catecismo/catecismo_s_pio_x/")!
    private let portugueseFacsimile = URL(string: "https://archive.org/details/catecismo-maior-de-sc3a3o-pio-x")!
    private let italianSource = URL(string: "https://it.wikisource.org/wiki/Compendio_della_dottrina_cristiana/Catechismo_maggiore")!
    private let englishSource = URL(string: "https://archive.org/details/catechism-of-pope-saint-pius-x")!
    private let spanishSource = URL(string: "https://archive.org/details/catecismo-mayor-de-san-pio-x-1906")!
    private let frenchFullSource = URL(string: "https://archive.org/details/catechisme-de-rome-de-st-pie-x-1905")!
    private let frenchAbridgedSource = URL(string: "https://archive.org/details/catechisme-de-rome-de-saint-pie-x-1912")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 9) {
                        Label("CATECISMO MAIOR · 1905", systemImage: "book.closed.fill")
                            .font(.caption.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(CatecismoTheme.gold)
                        Text("Catecismo Maior")
                            .font(CatecismoTheme.display(32))
                            .foregroundStyle(CatecismoTheme.ink)
                        Text("Edições históricas disponíveis para consulta.")
                            .font(.subheadline)
                            .foregroundStyle(CatecismoTheme.muted)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                    editionCards

                    Text("As edições abaixo abrem no navegador. O texto original é de domínio público; cada tradução precisa de revisão e de uma licença adequada antes de ser distribuída offline.")
                        .font(.footnote)
                        .foregroundStyle(CatecismoTheme.muted)
                        .padding(.horizontal, 4)
                }
                .frame(maxWidth: 820, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 18)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .navigationTitle("São Pio X")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder private var editionCards: some View {
        switch AppLanguage.contentTag(for: locale) {
        case "en":
            EditionSourceCard(
                language: "ENGLISH",
                title: "The Catechism of Pope Saint Pius X · 1911",
                summary: "English edition translated by Father John Hagan. The digitized book identifies this as an earlier Mantua catechism, not the Roman edition of 1905.",
                linkTitle: "Consult edition on Internet Archive",
                url: englishSource,
                note: "A new English translation of the Roman 1905 edition still needs editorial review."
            )
        case "es":
            EditionSourceCard(
                language: "ESPAÑOL",
                title: "Catecismo Mayor de San Pío X · 1906",
                summary: "Facsímil digitalizado de la versión castellana de 1906, con texto OCR.",
                linkTitle: "Consultar edición en Internet Archive",
                url: spanishSource,
                note: "La edición escaneada incluye una reserva editorial sobre reproducción; se enlaza como fuente y no se distribuye sin conexión."
            )
        case "fr":
            EditionSourceCard(
                language: "FRANÇAIS",
                title: "Catéchisme de Rome · édition complète de 1905",
                summary: "Traduction française de l’édition romaine complète, annoncée avec 993 questions et réponses.",
                linkTitle: "Consulter l’édition de 1905",
                url: frenchFullSource
            )
            EditionSourceCard(
                language: "FRANÇAIS · ÉDITION ABRÉGÉE",
                title: "Catéchisme de Rome · 1912",
                summary: "Édition abrégée, annoncée avec 433 questions et réponses. Le fichier numérique indique des conditions de réutilisation non commerciale.",
                linkTitle: "Consulter l’édition de 1912",
                url: frenchAbridgedSource
            )
        case "it":
            EditionSourceCard(
                language: "ITALIANO",
                title: "Catechismo maggiore",
                summary: "Edizione di Roma, Tipografia Vaticana, 1905, trascritta per parti e capitoli su Wikisource.",
                linkTitle: "Leggi su Wikisource",
                url: italianSource
            )
        default:
            EditionSourceCard(
                language: "PORTUGUÊS (BRASIL)",
                title: "Catecismo de São Pio X",
                summary: "Texto integral disponível na MONTFORT. O Internet Archive também oferece uma cópia digitalizada com OCR.",
                linkTitle: "Ler no MONTFORT",
                url: portugueseSource,
                secondaryLinkTitle: "Fac-símile · Internet Archive",
                secondaryURL: portugueseFacsimile,
                note: "A cópia do Internet Archive informa tradução não oficial e atualizações de 1976."
            )
            EditionSourceCard(
                language: "ITALIANO",
                title: "Catechismo maggiore",
                summary: "Edição de Roma, Tipografia Vaticana, 1905, transcrita por partes e capítulos na Wikisource.",
                linkTitle: "Leggi su Wikisource",
                url: italianSource
            )
        }
    }
}

private struct EditionSourceCard: View {
    let language: LocalizedStringKey
    let title: String
    let summary: LocalizedStringKey
    let linkTitle: LocalizedStringKey
    let url: URL
    var secondaryLinkTitle: LocalizedStringKey? = nil
    var secondaryURL: URL? = nil
    var note: LocalizedStringKey? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(language)
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(CatecismoTheme.gold)
            Text(title)
                .font(CatecismoTheme.display(21))
                .foregroundStyle(CatecismoTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(CatecismoTheme.muted)
                .lineSpacing(3)

            Link(destination: url) {
                Label(linkTitle, systemImage: "arrow.up.right.square")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if let secondaryLinkTitle, let secondaryURL {
                Link(secondaryLinkTitle, destination: secondaryURL)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(CatecismoTheme.navy)
            }

            if let note {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(CatecismoTheme.muted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CatecismoTheme.navy.opacity(0.06), lineWidth: 1)
        }
    }
}
