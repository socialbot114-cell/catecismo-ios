import SwiftUI

struct SaintPiusXView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let portugueseSource = URL(string: "https://www.montfort.org.br/bra/documentos/catecismo/catecismo_s_pio_x/")!
    private let portugueseFacsimile = URL(string: "https://archive.org/details/catecismo-maior-de-sc3a3o-pio-x")!
    private let italianSource = URL(string: "https://it.wikisource.org/wiki/Compendio_della_dottrina_cristiana/Catechismo_maggiore")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 9) {
                        Label("CATECISMO MAIOR · 1905", systemImage: "book.closed.fill")
                            .font(.caption.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(CatecismoTheme.gold)
                        Text("São Pio X")
                            .font(CatecismoTheme.display(32))
                            .foregroundStyle(CatecismoTheme.ink)
                        Text("Encontre edições em português e italiano do clássico catecismo em perguntas e respostas.")
                            .font(.subheadline)
                            .foregroundStyle(CatecismoTheme.muted)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                    EditionSourceCard(
                        language: "PORTUGUÊS (BRASIL)",
                        title: "Catecismo de São Pio X",
                        summary: "Texto integral publicado on-line pela Associação Cultural MONTFORT. O Internet Archive também disponibiliza uma edição digital com OCR; o próprio arquivo informa tradução não oficial e atualizações da edição de 1976.",
                        linkTitle: "Ler no MONTFORT",
                        url: portugueseSource,
                        secondaryLinkTitle: "Consultar edição digital no Internet Archive",
                        secondaryURL: portugueseFacsimile
                    )

                    EditionSourceCard(
                        language: "ITALIANO",
                        title: "Compendio della dottrina cristiana · Catechismo maggiore",
                        summary: "Transcrição italiana da edição de Roma, Tipografia Vaticana, 1905, organizada por partes e capítulos na Wikisource.",
                        linkTitle: "Leggi su Wikisource",
                        url: italianSource
                    )

                    Text("As fontes abrem no navegador e precisam de conexão. O original de 1905 está em domínio público; os direitos de traduções e transcrições devem ser avaliados conforme cada edição.")
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
}

private struct EditionSourceCard: View {
    let language: String
    let title: String
    let summary: String
    let linkTitle: String
    let url: URL
    var secondaryLinkTitle: String? = nil
    var secondaryURL: URL? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(language)
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(CatecismoTheme.gold)
            Text(title)
                .font(CatecismoTheme.display(23))
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
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CatecismoTheme.navy.opacity(0.06), lineWidth: 1)
        }
    }
}
