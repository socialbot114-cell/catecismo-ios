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
                        Text("Catecismo Maior")
                            .font(CatecismoTheme.display(32))
                            .foregroundStyle(CatecismoTheme.ink)
                        Text("Duas edições para consultar: português e italiano.")
                            .font(.subheadline)
                            .foregroundStyle(CatecismoTheme.muted)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

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
    var note: String? = nil

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
