import SwiftUI
import UIKit

private enum AppSection: CaseIterable, Identifiable {
    case home, library, topics, saved

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .home: "Início"
        case .library: "Biblioteca"
        case .topics: "Temas"
        case .saved: "Minha biblioteca"
        }
    }

    var accessibilityID: String {
        switch self {
        case .home: "section-home"
        case .library: "section-library"
        case .topics: "section-topics"
        case .saved: "section-saved"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .library: return "books.vertical.fill"
        case .topics: return "square.grid.2x2.fill"
        case .saved: return "bookmark.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage(AppLanguage.preferenceKey) private var languageSelection = AppLanguageChoice.system.rawValue
    @State private var selectedSection = AppSection.home

    private var selectedLocale: Locale { AppLanguage.locale(for: languageSelection) }

    var body: some View {
        Group {
            switch library.loadState {
            case .loading:
                VStack(spacing: 14) {
                    ProgressView().controlSize(.large)
                    Text("Preparando sua biblioteca…").font(.headline)
                        .foregroundStyle(CatecismoTheme.ink)
                    Text("Os guias estão sendo carregados para leitura offline.")
                        .font(.subheadline).foregroundStyle(CatecismoTheme.muted)
                }
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CatecismoTheme.canvas.ignoresSafeArea())
            case .failed(let message):
                ContentUnavailableView {
                    Label("Não foi possível abrir a biblioteca", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Tentar novamente") {
                        library.load(languageCode: AppLanguage.contentTag(for: selectedLocale))
                    }
                    .buttonStyle(.borderedProminent)
                }
                .background(CatecismoTheme.canvas.ignoresSafeArea())
            case .loaded:
                if horizontalSizeClass == .regular {
                    splitView
                } else {
                    tabView
                }
            }
        }
        .environment(\.locale, selectedLocale)
        .tint(CatecismoTheme.accent)
        // The palette is designed for a light paper look; keep system controls consistent with it.
        .preferredColorScheme(.light)
        .task {
            if library.loadState == .loading {
                library.load(languageCode: AppLanguage.contentTag(for: selectedLocale))
            }
        }
        .onChange(of: languageSelection) { _, selection in
            library.load(languageCode: AppLanguage.contentTag(for: AppLanguage.locale(for: selection)))
        }
    }

    private var tabView: some View {
        VStack(spacing: 0) {
            destination(for: selectedSection)
            bottomNavigation
        }
        .background(CatecismoTheme.paper.ignoresSafeArea(edges: .bottom))
    }

    private var bottomNavigation: some View {
        HStack(spacing: 6) {
            ForEach(AppSection.allCases) { section in
                let isSelected = selectedSection == section
                Button { selectedSection = section } label: {
                    VStack(spacing: 5) {
                        Image(systemName: section.icon)
                            .font(.system(size: 20, weight: .semibold))
                        Text(section.title)
                            .font(.caption2.weight(isSelected ? .semibold : .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(isSelected ? CatecismoTheme.navy : CatecismoTheme.muted)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 54)
                    .background(isSelected ? CatecismoTheme.canvas : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(section.title))
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilityIdentifier(section.accessibilityID)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 7)
        .padding(.bottom, 7)
        .background(CatecismoTheme.paper.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle().fill(CatecismoTheme.navy.opacity(0.06)).frame(height: 1)
        }
    }

    private var splitView: some View {
        NavigationSplitView {
            List {
                ForEach(AppSection.allCases) { section in
                    let isSelected = selectedSection == section
                    Button { selectedSection = section } label: {
                        Label(section.title, systemImage: section.icon)
                            .fontWeight(isSelected ? .semibold : .regular)
                            .foregroundStyle(isSelected ? CatecismoTheme.navy : CatecismoTheme.ink)
                    }
                    .listRowBackground(isSelected ? CatecismoTheme.paper : Color.clear)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    .accessibilityIdentifier(section.accessibilityID)
                }
            }
            .scrollContentBackground(.hidden)
            .background(CatecismoTheme.canvas)
            .navigationTitle(String(localized: "Catecismo", locale: selectedLocale))
        } detail: {
            destination(for: selectedSection)
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder private func destination(for section: AppSection) -> some View {
        switch section {
        case .home: HomeView()
        case .library: LibraryView()
        case .topics: TopicsView()
        case .saved: MyLibraryView(language: $languageSelection)
        }
    }
}

private struct HomeView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var featuredGuide: Guide? { library.guides.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    hero

                    if let guide = library.continueReadingGuide {
                        SectionHeading(title: "Continue sua leitura", subtitle: "Retome de onde você parou")
                        NavigationLink { GuideDetailView(guide: guide) } label: {
                            GuideCard(guide: guide, detail: true, actionTitle: "Retomar")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("home-continue-reading")
                    }

                    let catechismParts = library.guides.filter(\.isCatechism)
                    if !catechismParts.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeading(title: "Catecismo em quatro partes", subtitle: "Edição em português · leitura offline")
                            guideGrid(catechismParts)
                            Text("Fonte: PDF da Diocese de Miracema. §§2217 e 2439 incluídos no texto offline.")
                                .font(.footnote)
                                .foregroundStyle(CatecismoTheme.muted)
                        }
                        .accessibilityIdentifier("home-catechism-section")
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeading(title: "Comece a ler", subtitle: "Guias breves para refletir no seu ritmo")
                        let authoredGuides = library.guides.filter { !$0.isCatechism }
                        if authoredGuides.isEmpty {
                            ContentUnavailableView("Nenhum guia disponível", systemImage: "books.vertical")
                        } else {
                            guideGrid(Array(authoredGuides.prefix(3)))
                        }
                    }

                    DisclosureGroup("Sobre este aplicativo") {
                        Text("Aplicativo independente e não oficial. Inclui guias autorais e quatro partes do Catecismo transcritas da edição em português no PDF da Diocese de Miracema. O texto fica armazenado no aparelho para leitura offline.")
                            .font(.footnote)
                            .foregroundStyle(CatecismoTheme.muted)
                            .padding(.top, 8)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CatecismoTheme.navy)
                    .padding(18)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    HStack(spacing: 14) {
                        Image(systemName: "wifi.slash")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(CatecismoTheme.gold)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Sua biblioteca, sempre com você")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CatecismoTheme.ink)
                            Text("Todo o conteúdo funciona offline.")
                                .font(.footnote).foregroundStyle(CatecismoTheme.muted)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(18)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .frame(maxWidth: 960, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
            }
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .safeAreaPadding(.bottom, 14)
            .accessibilityIdentifier("screen-home")
            .navigationTitle(String(localized: "Início", locale: locale))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var hero: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 14) {
                Label("LEITURA E REFLEXÃO", systemImage: "sparkle")
                    .font(.caption.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(CatecismoTheme.gold)

                Text("Catecismo")
                    .font(CatecismoTheme.display(horizontalSizeClass == .regular ? 38 : 32))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Text("Conheça a fé, um guia por vez.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)

                if let guide = featuredGuide {
                    NavigationLink { GuideDetailView(guide: guide) } label: {
                        Label("Começar leitura", systemImage: "arrow.right")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .background(CatecismoTheme.gold, in: Capsule())
                            .foregroundStyle(CatecismoTheme.navyDeep)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ComponentArtwork(name: "component-book")
                .frame(width: horizontalSizeClass == .regular ? 230 : 142, height: horizontalSizeClass == .regular ? 220 : 180)
                .accessibilityHidden(true)
        }
        .padding(horizontalSizeClass == .regular ? 28 : 18)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: [CatecismoTheme.navy, CatecismoTheme.navyDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(CatecismoTheme.gold.opacity(0.12))
                .frame(width: 170, height: 170)
                .blur(radius: 1)
                .offset(x: 48, y: -62)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: CatecismoTheme.navy.opacity(0.14), radius: 18, x: 0, y: 10)
    }

    @ViewBuilder private func guideGrid(_ guides: [Guide]) -> some View {
        if horizontalSizeClass == .regular {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide) }
                        .buttonStyle(.plain)
                }
            }
        } else {
            VStack(spacing: 12) {
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide) }
                        .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct LibraryView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var query = ""
    @State private var results = LibrarySearchResults()
    @State private var searchedQuery = ""
    @FocusState private var searchFocused: Bool

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var matchedGuides: [Guide] { results.guideIDs.compactMap(library.guide(withID:)) }
    private var isSearchPending: Bool { !trimmedQuery.isEmpty && searchedQuery != trimmedQuery }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Encontre seu próximo guia")
                                .font(CatecismoTheme.display(30))
                                .foregroundStyle(CatecismoTheme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Busque por palavra, tema ou número do parágrafo (ex.: §1691).")
                                .font(.subheadline).foregroundStyle(CatecismoTheme.muted)
                        }
                        Spacer(minLength: 0)
                        ComponentArtwork(name: "component-library")
                            .frame(width: 112, height: 100)
                            .accessibilityHidden(true)
                    }

                    searchField

                    if trimmedQuery.isEmpty {
                        if library.guides.isEmpty {
                            emptyState(title: "Nenhum guia disponível", message: "Não há conteúdo para mostrar.", symbol: "books.vertical")
                        } else {
                            guideGrid(library.guides)
                        }
                    } else if isSearchPending && results.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 120)
                    } else if results.isEmpty {
                        emptyState(title: "Nenhum resultado", message: "Tente buscar por outro título ou tema.", symbol: "magnifyingglass")
                    } else {
                        if !matchedGuides.isEmpty {
                            guideGrid(matchedGuides)
                        }
                        if !results.hits.isEmpty {
                            SectionHeading(title: "Trechos encontrados", subtitle: "Toque para abrir o parágrafo")
                            LazyVStack(spacing: 10) {
                                ForEach(results.hits) { hit in
                                    if let guide = library.guide(withID: hit.guideID) {
                                        NavigationLink {
                                            GuideDetailView(guide: guide, target: ReadingPosition(chapter: hit.chapterIndex, paragraph: hit.paragraphIndex))
                                        } label: {
                                            SearchHitRow(guide: guide, hit: hit)
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityIdentifier("search-hit")
                                    }
                                }
                            }
                            if results.truncated {
                                Text("Mostrando os primeiros \(LibrarySearchIndex.maxHits) trechos. Refine a busca para ver outros.")
                                    .font(.footnote)
                                    .foregroundStyle(CatecismoTheme.muted)
                            }
                        }
                    }
                }
                .frame(maxWidth: 960, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 12)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .safeAreaPadding(.bottom, 16)
            .accessibilityIdentifier("screen-library")
            .navigationTitle(String(localized: "Biblioteca", locale: locale))
            .navigationBarTitleDisplayMode(.inline)
            .task(id: "\(library.contentVersion)|\(trimmedQuery)") {
                await runSearch(trimmedQuery)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(CatecismoTheme.navy)
            TextField("Buscar palavra, tema ou parágrafo", text: $query)
                .focused($searchFocused)
                .submitLabel(.search)
                .onSubmit { searchFocused = false }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier("library-search-field")
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(CatecismoTheme.muted)
                }
                .accessibilityLabel("Limpar busca")
                .accessibilityIdentifier("library-clear-search")
            }
        }
        .font(.body)
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .background(CatecismoTheme.paper, in: Capsule())
        .overlay(Capsule().stroke(CatecismoTheme.navy.opacity(0.08), lineWidth: 1))
    }

    /// Debounced and run off the main thread: the Catechism alone has almost 3,000 paragraphs.
    private func runSearch(_ term: String) async {
        guard !term.isEmpty else {
            results = LibrarySearchResults()
            searchedQuery = ""
            return
        }
        try? await Task.sleep(nanoseconds: 220_000_000)
        guard !Task.isCancelled else { return }
        let index = library.searchIndex
        let found = await Task.detached(priority: .userInitiated) { index.search(term) }.value
        guard !Task.isCancelled else { return }
        results = found
        searchedQuery = term
    }

    private func emptyState(title: LocalizedStringKey, message: LocalizedStringKey, symbol: String) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: symbol)
        } description: {
            Text(message)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @ViewBuilder private func guideGrid(_ guides: [Guide]) -> some View {
        if horizontalSizeClass == .regular {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide, detail: true) }
                        .buttonStyle(.plain)
                }
            }
        } else {
            LazyVStack(spacing: 12) {
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide, detail: true) }
                        .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct SearchHitRow: View {
    let guide: Guide
    let hit: SearchHit

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(guide.title.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.6)
                .foregroundStyle(CatecismoTheme.gold)
                .lineLimit(1)
            Text(hit.chapterTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CatecismoTheme.navy)
                .lineLimit(2)
            Text(hit.snippet)
                .font(.system(.callout, design: .serif))
                .foregroundStyle(CatecismoTheme.ink)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct TopicsView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var categories: [String] { Array(Set(library.guides.map(\.category))).sorted() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeading(title: "Explore por tema", subtitle: "Escolha um caminho para aprofundar")

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: horizontalSizeClass == .regular ? 3 : 2), spacing: 14) {
                        ForEach(categories, id: \.self) { category in
                            let guides = library.guides.filter { $0.category == category }
                            NavigationLink {
                                TopicGuidesView(category: category, guides: guides)
                            } label: {
                                TopicCategoryCard(category: category, guides: guides)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("topic-category-\(category)")
                        }
                    }
                }
                .frame(maxWidth: 960, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 18)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .safeAreaPadding(.bottom, 16)
            .accessibilityIdentifier("screen-topics")
            .navigationTitle(String(localized: "Temas", locale: locale))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct MyLibraryView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var language: String
    @State private var quotePendingRemoval: Quote?
    private var favoriteGuides: [Guide] { library.guides.filter { library.isFavorite($0.id) } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeading(title: "Minha biblioteca", subtitle: "Seu caminho de leitura, salvo neste aparelho")
                        .accessibilityIdentifier("my-library-heading")

                    HStack(spacing: 12) {
                        StatCard(value: "\(library.startedGuideCount)", label: "Guias iniciados", symbol: "book.pages.fill")
                        StatCard(value: "\(library.readingMinutes) min", label: "Tempo de leitura", symbol: "clock.fill")
                    }

                    HStack {
                        Label("Idioma do app", systemImage: "globe")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CatecismoTheme.navy)
                        Spacer()
                        Picker("Idioma do app", selection: $language) {
                            ForEach(AppLanguageChoice.allCases) { choice in
                                Text(choice.title).tag(choice.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .accessibilityIdentifier("app-language-picker")
                    }
                    .padding(16)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeading(title: "Favoritos", subtitle: "Guias que você marcou")
                            .accessibilityIdentifier("my-library-favorites-heading")
                        if favoriteGuides.isEmpty {
                            EmptyStateCard(symbol: "heart", title: "Seus favoritos aparecerão aqui", message: "Toque no coração de um guia para guardá-lo nesta biblioteca.")
                        } else {
                            ForEach(favoriteGuides) { guide in
                                NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeading(title: "Citações", subtitle: "Trechos guardados durante a leitura")
                            .accessibilityIdentifier("my-library-quotes-heading")
                        if library.quotes.isEmpty {
                            EmptyStateCard(symbol: "quote.opening", title: "Ainda não há citações", message: "Salve um trecho no leitor para encontrá-lo aqui.")
                        } else {
                            ForEach(library.quotes.reversed()) { quote in
                                quoteRow(quote)
                            }
                        }
                    }
                }
                .frame(maxWidth: 960, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 18)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .safeAreaPadding(.bottom, 16)
            .accessibilityIdentifier("screen-saved")
            .navigationTitle(String(localized: "Minha biblioteca", locale: locale))
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Remover esta citação?",
                isPresented: Binding(get: { quotePendingRemoval != nil }, set: { if !$0 { quotePendingRemoval = nil } }),
                titleVisibility: .visible,
                presenting: quotePendingRemoval
            ) { quote in
                Button("Remover citação", role: .destructive) { library.removeQuote(quote) }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }

    private func source(of quote: Quote) -> String? {
        guard let guide = library.guide(withID: quote.guideID) else { return nil }
        var parts = [guide.title]
        if guide.isCatechism, let number = LibrarySearchIndex.catechismNumber(of: quote.text) {
            parts.append("§\(number)")
        } else if let chapter = quote.chapterIndex, guide.chapters.indices.contains(chapter) {
            parts.append(guide.chapters[chapter].title)
        }
        return parts.joined(separator: " · ")
    }

    private func position(of quote: Quote, in guide: Guide) -> ReadingPosition? {
        if let chapter = quote.chapterIndex, let paragraph = quote.paragraphIndex,
           guide.chapters.indices.contains(chapter), guide.chapters[chapter].paragraphs.indices.contains(paragraph),
           guide.chapters[chapter].paragraphs[paragraph] == quote.text {
            return ReadingPosition(chapter: chapter, paragraph: paragraph)
        }
        // Quotes saved before 1.2.2 have no location; find the passage by its text.
        for (chapterIndex, chapter) in guide.chapters.enumerated() {
            if let paragraph = chapter.paragraphs.firstIndex(of: quote.text) {
                return ReadingPosition(chapter: chapterIndex, paragraph: paragraph)
            }
        }
        return nil
    }

    @ViewBuilder private func quoteRow(_ quote: Quote) -> some View {
        let sourceLabel = source(of: quote)
        let shareText = sourceLabel.map { "“\(quote.text)”\n— \($0)" } ?? "“\(quote.text)”"
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "quote.opening")
                .foregroundStyle(CatecismoTheme.gold)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: "“\(quote.text)”")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(CatecismoTheme.ink)
                if let guide = library.guide(withID: quote.guideID), let sourceLabel {
                    NavigationLink {
                        GuideDetailView(guide: guide, target: position(of: quote, in: guide))
                    } label: {
                        Label(sourceLabel, systemImage: "arrow.up.right")
                            .labelStyle(TrailingIconLabelStyle())
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(CatecismoTheme.navy)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(Text("Abrir o trecho no leitor"))
                    .accessibilityIdentifier("quote-open-source")
                }
            }
            Spacer(minLength: 0)
            VStack(spacing: 6) {
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 36, height: 36)
                }
                .accessibilityLabel(Text("Compartilhar citação"))
                Button(role: .destructive) { quotePendingRemoval = quote } label: {
                    Image(systemName: "trash")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 36, height: 36)
                }
                .accessibilityLabel("Remover citação")
            }
        }
        .padding(18)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            configuration.title
            configuration.icon.imageScale(.small)
        }
    }
}

private struct GuideDetailView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(ReaderTextSize.preferenceKey) private var textSizeSelection = ReaderTextSize.standard.rawValue
    @StateObject private var speech = SpeechReader()
    @State private var selectedChapter = 0
    @State private var visibleParagraphs: Set<Int> = []
    @State private var didRestore = false
    @State private var scrollRequest: ScrollRequest?
    @State private var highlightedParagraph: Int?
    @State private var sessionStart: Date?
    @State private var quoteSavedCount = 0
    let guide: Guide
    var target: ReadingPosition? = nil

    private struct ScrollRequest: Equatable {
        let id = UUID()
        /// nil scrolls to the top of the chapter.
        let paragraph: Int?
        var animated = false
    }

    private static let chapterTopID = "chapter-top"
    private var textSize: ReaderTextSize { ReaderTextSize(rawValue: textSizeSelection) ?? .standard }
    private var speechKey: String { "\(guide.storageKey)#\(selectedChapter)" }
    private var isSpeechForThisChapter: Bool { speech.sourceKey == speechKey && speech.isActive }
    private var topVisibleParagraph: Int { visibleParagraphs.min() ?? 0 }

    private var chapter: Chapter? {
        guard guide.chapters.indices.contains(selectedChapter) else { return nil }
        return guide.chapters[selectedChapter]
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    guideHeader

                    DisclosureGroup {
                        Text(guide.context)
                            .font(.body)
                            .foregroundStyle(CatecismoTheme.muted)
                            .lineSpacing(4)
                            .padding(.top, 8)
                    } label: {
                        Label("Contexto do guia", systemImage: "info.circle")
                            .font(.headline)
                            .foregroundStyle(CatecismoTheme.navy)
                    }
                    .padding(18)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    if guide.isCatechism {
                        Text("Fonte: PDF da Diocese de Miracema. §§2217 e 2439 incluídos no texto offline.")
                            .font(.footnote)
                            .foregroundStyle(CatecismoTheme.muted)
                            .accessibilityIdentifier("catechism-source-note")
                    }

                    if let chapter {
                        reader(chapter)
                    } else {
                        ContentUnavailableView {
                            Label("Guia sem capítulos", systemImage: "doc.text.magnifyingglass")
                        } description: {
                            Text("Este guia ainda não tem conteúdo disponível para leitura.")
                        }
                        .frame(maxWidth: .infinity, minHeight: 240)
                        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }
                .frame(maxWidth: 820, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 16)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .safeAreaPadding(.bottom, 16)
            .accessibilityIdentifier("screen-reader")
            .navigationTitle(String(localized: "Leitura", locale: locale))
            .navigationBarTitleDisplayMode(.inline)
            .sensoryFeedback(.success, trigger: quoteSavedCount)
            .onAppear {
                // The Catechism is Portuguese in every UI language, so the voice follows the text, not the interface.
                speech.setLanguage(guide.contentLanguage)
                sessionStart = Date()
                restorePositionIfNeeded()
            }
            .onDisappear {
                speech.stop()
                saveReadingState()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    if sessionStart == nil { sessionStart = Date() }
                } else {
                    saveReadingState()
                }
            }
            .onChange(of: selectedChapter) { oldValue, _ in
                if speech.sourceKey == "\(guide.storageKey)#\(oldValue)" { speech.stop() }
                visibleParagraphs = []
                if scrollRequest == nil {
                    highlightedParagraph = nil
                    scrollRequest = ScrollRequest(paragraph: nil)
                    library.savePosition(ReadingPosition(chapter: selectedChapter, paragraph: 0), for: guide)
                }
            }
            .onChange(of: scrollRequest) { _, request in
                guard let request else { return }
                let destination = request.paragraph.map { paragraphScrollID($0) } ?? Self.chapterTopID
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if request.animated {
                        withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(destination, anchor: .top) }
                    } else {
                        proxy.scrollTo(destination, anchor: .top)
                    }
                    if scrollRequest == request { scrollRequest = nil }
                }
            }
            .onChange(of: speech.currentParagraphIndex) { _, index in
                guard isSpeechForThisChapter, index >= 0, !visibleParagraphs.contains(index) || index == visibleParagraphs.max() else { return }
                scrollRequest = ScrollRequest(paragraph: index, animated: true)
            }
        }
    }

    private func paragraphScrollID(_ index: Int) -> String { "paragraph-\(index)" }

    private func restorePositionIfNeeded() {
        guard !didRestore else { return }
        didRestore = true
        let requested = target.flatMap { guide.chapters.indices.contains($0.chapter) ? $0 : nil }
        guard let position = requested ?? library.position(for: guide) else { return }
        highlightedParagraph = requested?.paragraph
        let request = position.paragraph > 0 || requested != nil ? ScrollRequest(paragraph: position.paragraph) : nil
        scrollRequest = request
        if position.chapter != selectedChapter {
            if request == nil { scrollRequest = ScrollRequest(paragraph: nil) }
            selectedChapter = position.chapter
        }
    }

    private func saveReadingState() {
        if let sessionStart {
            library.addReadingTime(Date().timeIntervalSince(sessionStart))
            self.sessionStart = nil
        }
        guard chapter != nil else { return }
        library.savePosition(ReadingPosition(chapter: selectedChapter, paragraph: topVisibleParagraph), for: guide)
    }

    private var guideHeader: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedStringKey(guide.category))
                    .textCase(.uppercase)
                    .font(.caption.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(CatecismoTheme.gold)
                Text(guide.title)
                    .font(CatecismoTheme.display(30))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(guide.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.84))
                    .fixedSize(horizontal: false, vertical: true)
                Text(guide.isCatechism
                     ? "EDIÇÃO EM PORTUGUÊS · \(guide.chapterCount) SEÇÕES"
                     : "GUIA AUTORAL  ·  \(guide.chapterCount) CAPÍTULOS")
                    .font(.caption2.weight(.semibold))
                    .tracking(0.6)
                    .foregroundStyle(.white.opacity(0.64))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let imageName = GuideArtwork.imageName(for: guide.id) {
                ComponentArtwork(name: imageName)
                    .frame(width: horizontalSizeClass == .regular ? 170 : 112, height: horizontalSizeClass == .regular ? 180 : 132)
                    .accessibilityHidden(true)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [CatecismoTheme.navy, CatecismoTheme.navyDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }

    @ViewBuilder private func reader(_ chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CAPÍTULO \(selectedChapter + 1) DE \(guide.chapterCount)")
                        .font(.caption.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(CatecismoTheme.muted)
                    Text(chapter.title)
                        .font(CatecismoTheme.display(25))
                        .foregroundStyle(CatecismoTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("selected-chapter-title")
                }
                Spacer(minLength: 8)
                readerOptionsMenu
                Menu {
                    Picker("Capítulo", selection: $selectedChapter) {
                        ForEach(guide.chapters.indices, id: \.self) { index in
                            Text(guide.chapters[index].title).tag(index)
                        }
                    }
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.headline)
                        .frame(width: 42, height: 42)
                        .background(CatecismoTheme.canvas, in: Circle())
                        .foregroundStyle(CatecismoTheme.navy)
                }
                .accessibilityIdentifier("chapter-picker-button")
                .accessibilityLabel("Escolher capítulo")
            }
            .id(Self.chapterTopID)

            playerControls(for: chapter)

            Rectangle().fill(CatecismoTheme.canvas).frame(height: 1)

            if chapter.paragraphs.isEmpty {
                ContentUnavailableView("Capítulo vazio", systemImage: "doc")
            } else {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(chapter.paragraphs.indices, id: \.self) { paragraphOffset in
                        paragraphRow(chapter.paragraphs[paragraphOffset], offset: paragraphOffset)
                    }
                }
            }

            Button {
                library.completeChapter(at: selectedChapter, in: guide)
                if selectedChapter + 1 < guide.chapterCount { selectedChapter += 1 }
            } label: {
                Label(selectedChapter + 1 < guide.chapterCount ? "Concluir e avançar" : "Concluir guia", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 4)
            .accessibilityIdentifier("complete-chapter-button")
        }
        .padding(20)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @ViewBuilder private func paragraphRow(_ paragraph: String, offset: Int) -> some View {
        let isQuoted = library.hasQuote(guideID: guide.id, text: paragraph)
        let isHighlighted = (isSpeechForThisChapter && speech.currentParagraphIndex == offset) || highlightedParagraph == offset
        HStack(alignment: .top, spacing: 12) {
            Text(paragraph)
                .font(textSize.font)
                .foregroundStyle(CatecismoTheme.ink)
                .lineSpacing(7)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(paragraphAccessibilityIdentifier(paragraph, offset: offset))
            Button {
                if library.addQuote(guideID: guide.id, text: paragraph, chapterIndex: selectedChapter, paragraphIndex: offset) {
                    quoteSavedCount += 1
                }
            } label: {
                Image(systemName: isQuoted ? "checkmark.circle.fill" : "quote.opening")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CatecismoTheme.gold)
                    .padding(8)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .disabled(isQuoted)
            .accessibilityLabel(isQuoted ? "Citação salva" : "Salvar como citação")
            .accessibilityHint(String(paragraph.prefix(80)))
            .accessibilityIdentifier("save-quote-button")
        }
        .padding(.vertical, isHighlighted ? 8 : 0)
        .padding(.horizontal, isHighlighted ? 8 : 0)
        .background(isHighlighted ? CatecismoTheme.highlight : Color.clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .id(paragraphScrollID(offset))
        .onAppear { visibleParagraphs.insert(offset) }
        .onDisappear { visibleParagraphs.remove(offset) }
    }

    @ViewBuilder private func playerControls(for chapter: Chapter) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    if isSpeechForThisChapter {
                        speech.togglePlayPause()
                    } else {
                        speech.speak(
                            chapter.paragraphs,
                            startAt: topVisibleParagraph,
                            sourceKey: speechKey,
                            title: chapter.title,
                            subtitle: guide.title
                        )
                    }
                } label: {
                    let isPlaying = isSpeechForThisChapter && speech.isSpeaking
                    let isPaused = isSpeechForThisChapter && speech.isPaused
                    Label(isPlaying ? "Pausar" : isPaused ? "Continuar" : "Ouvir", systemImage: isPlaying ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("speech-play-button")

                Button { library.toggleFavorite(guide.id) } label: {
                    Label(library.isFavorite(guide.id) ? "Salvo" : "Salvar", systemImage: library.isFavorite(guide.id) ? "heart.fill" : "heart")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("guide-favorite-button")
                .accessibilityLabel(library.isFavorite(guide.id) ? "Remover dos favoritos" : "Adicionar aos favoritos")
            }

            if isSpeechForThisChapter {
                HStack(spacing: 18) {
                    Button { speech.previous() } label: { Image(systemName: "backward.fill") }
                        .accessibilityLabel("Parágrafo anterior")
                        .disabled(speech.currentParagraphIndex <= 0)
                    Button { speech.stop() } label: { Image(systemName: "stop.fill") }
                        .accessibilityLabel("Parar narração")
                        .accessibilityIdentifier("speech-stop-button")
                    Button { speech.next() } label: { Image(systemName: "forward.fill") }
                        .accessibilityLabel("Próximo parágrafo")
                        .disabled(speech.currentParagraphIndex + 1 >= speech.totalParagraphs)
                    Spacer(minLength: 0)
                    Text("Parágrafo \(max(speech.currentParagraphIndex, 0) + 1) de \(speech.totalParagraphs)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CatecismoTheme.muted)
                        .monospacedDigit()
                }
                .font(.headline)
                .foregroundStyle(CatecismoTheme.navy)
                .buttonStyle(.borderless)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(CatecismoTheme.canvas, in: Capsule())
            }
        }
    }

    private var readerOptionsMenu: some View {
        Menu {
            Picker(selection: $textSizeSelection) {
                ForEach(ReaderTextSize.allCases) { size in
                    Text(size.title).tag(size.rawValue)
                }
            } label: {
                Label("Tamanho do texto", systemImage: "textformat.size")
            }
            .pickerStyle(.menu)

            Picker(selection: Binding(get: { speech.rate }, set: { speech.setRate($0) })) {
                ForEach(SpeechRate.allCases) { rate in
                    Text(verbatim: rate.label).tag(rate)
                }
            } label: {
                Label("Velocidade da voz", systemImage: "speedometer")
            }
            .pickerStyle(.menu)

            Menu {
                Button { speech.useDefaultVoice() } label: {
                    if speech.selectedVoiceIdentifier == nil {
                        Label("Voz padrão", systemImage: "checkmark")
                    } else {
                        Text("Voz padrão")
                    }
                }
                ForEach(speech.voices, id: \.identifier) { voice in
                    Button { speech.chooseVoice(voice) } label: {
                        if speech.selectedVoiceIdentifier == voice.identifier {
                            Label(voice.name, systemImage: "checkmark")
                        } else {
                            Text(verbatim: voice.name)
                        }
                    }
                }
            } label: {
                Label("Voz", systemImage: "person.wave.2")
            }
        } label: {
            Image(systemName: "textformat.size")
                .font(.headline)
                .frame(width: 42, height: 42)
                .background(CatecismoTheme.canvas, in: Circle())
                .foregroundStyle(CatecismoTheme.navy)
        }
        .accessibilityIdentifier("reader-options-button")
        .accessibilityLabel("Opções de leitura")
    }

    private func paragraphAccessibilityIdentifier(_ paragraph: String, offset: Int) -> String {
        guard guide.isCatechism, let number = LibrarySearchIndex.catechismNumber(of: paragraph) else {
            return "reader-paragraph-\(selectedChapter)-\(offset)"
        }
        return "catechism-paragraph-\(number)"
    }
}

private struct SectionHeading: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(CatecismoTheme.display(24))
                .foregroundStyle(CatecismoTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(CatecismoTheme.muted)
            }
        }
    }
}

private struct GuideCard: View {
    @EnvironmentObject private var library: LibraryViewModel
    let guide: Guide
    var detail = false
    var actionTitle: LocalizedStringKey? = nil

    private var progress: Double { library.completion(for: guide) }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(CatecismoTheme.canvas)
                if let imageName = GuideArtwork.imageName(for: guide.id) {
                    ComponentArtwork(name: imageName).padding(5)
                } else {
                    Image(systemName: "book.closed.fill")
                        .font(.title2)
                        .foregroundStyle(CatecismoTheme.gold)
                }
            }
            .frame(width: 78, height: 84)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(LocalizedStringKey(guide.category))
                    .textCase(.uppercase)
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(CatecismoTheme.gold)
                Text(guide.title)
                    .font(.headline)
                    .foregroundStyle(CatecismoTheme.ink)
                    .multilineTextAlignment(.leading)
                Group {
                    if detail {
                        Text(guide.description)
                    } else {
                        Text(LocalizedStringKey(guide.category))
                    }
                }
                .font(.subheadline)
                .foregroundStyle(CatecismoTheme.muted)
                .lineLimit(detail ? 2 : 1)

                if progress > 0 {
                    ProgressView(value: progress)
                        .tint(CatecismoTheme.navy)
                        .accessibilityLabel(Text("Progresso"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let actionTitle {
                Text(actionTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CatecismoTheme.navy)
            } else {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CatecismoTheme.navy.opacity(0.58))
            }
        }
        .padding(14)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CatecismoTheme.navy.opacity(0.06), lineWidth: 1)
        }
    }
}

private struct TopicCategoryCard: View {
    let category: String
    let guides: [Guide]

    /// Chosen from the guides themselves, so the artwork does not depend on the translated category name.
    private var artwork: String {
        guides.lazy.compactMap { GuideArtwork.imageName(for: $0.id) }.first ?? "component-book"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ComponentArtwork(name: artwork)
                .frame(maxWidth: .infinity)
                .frame(height: 92)
                .padding(.vertical, 6)
                .accessibilityHidden(true)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(LocalizedStringKey(category))
                    .font(.headline)
                    .foregroundStyle(CatecismoTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CatecismoTheme.navy.opacity(0.58))
            }
            let guideCountLabel: LocalizedStringKey = guides.count == 1 ? "1 guia" : "\(guides.count) guias"
            Text(guideCountLabel)
                .font(.caption)
                .foregroundStyle(CatecismoTheme.muted)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CatecismoTheme.navy.opacity(0.06), lineWidth: 1)
        }
    }
}

private struct TopicGuidesView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let category: String
    let guides: [Guide]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                let guideCountLabel: LocalizedStringKey = guides.count == 1 ? "1 guia para explorar" : "\(guides.count) guias para explorar"
                SectionHeading(title: LocalizedStringKey(category), subtitle: guideCountLabel)
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide, detail: true) }
                        .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: 820, alignment: .leading)
            .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
            .padding(.top, 18)
            .padding(.bottom, 30)
            .frame(maxWidth: .infinity)
        }
        .background(CatecismoTheme.canvas.ignoresSafeArea())
        .navigationTitle(Text(LocalizedStringKey(category)))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("screen-topic-detail")
    }
}

private struct StatCard: View {
    let value: String
    let label: LocalizedStringKey
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(CatecismoTheme.gold)
            Text(value)
                .font(CatecismoTheme.display(26))
                .foregroundStyle(CatecismoTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption)
                .foregroundStyle(CatecismoTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct EmptyStateCard: View {
    let symbol: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(CatecismoTheme.gold)
                .frame(width: 44, height: 44)
                .background(CatecismoTheme.canvas, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(CatecismoTheme.ink)
                Text(message).font(.footnote).foregroundStyle(CatecismoTheme.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct ComponentArtwork: View {
    let name: String

    var body: some View {
        Group {
            if let image = ComponentArtworkCache.image(named: name) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "book.closed.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(CatecismoTheme.gold)
                    .padding(20)
            }
        }
    }
}

/// Decoding the PNGs on every body evaluation was wasteful; keep each image once.
private enum ComponentArtworkCache {
    private static let cache = NSCache<NSString, UIImage>()

    static func image(named name: String) -> UIImage? {
        if let cached = cache.object(forKey: name as NSString) { return cached }
        guard let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "Images"),
              let image = UIImage(contentsOfFile: url.path) else { return nil }
        cache.setObject(image, forKey: name as NSString)
        return image
    }
}

private enum GuideArtwork {
    static func imageName(for guideID: String) -> String? {
        switch guideID {
        case "o-dom-da-fe": return "component-book"
        case "credo-em-caminho": return "component-cross"
        case "sinais-da-graca": return "component-dove"
        case "escola-da-oracao": return "component-rosary"
        case "a-igreja-viva": return "component-church"
        default: return nil
        }
    }
}
