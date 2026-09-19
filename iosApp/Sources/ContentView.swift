import SwiftUI

private enum AppSection: String, CaseIterable, Identifiable {
    case home = "Início"
    case library = "Biblioteca"
    case topics = "Temas"
    case saved = "Minha biblioteca"

    var id: Self { self }
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
    @State private var selectedSection = AppSection.home

    var body: some View {
        Group {
            switch library.loadState {
            case .loading:
                VStack(spacing: 14) {
                    ProgressView().controlSize(.large)
                    Text("Preparando sua biblioteca…").font(.headline)
                    Text("Os guias estão sendo carregados para leitura offline.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding()
            case .failed(let message):
                ContentUnavailableView {
                    Label("Não foi possível abrir a biblioteca", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Tentar novamente", action: library.load).buttonStyle(.borderedProminent)
                }
            case .loaded:
                if horizontalSizeClass == .regular {
                    splitView
                } else {
                    tabView
                }
            }
        }
        .tint(.indigo)
        .task {
            if library.loadState == .loading { library.load() }
        }
    }

    private var tabView: some View {
        TabView(selection: $selectedSection) {
            destination(for: .home).tabItem { Label(AppSection.home.rawValue, systemImage: AppSection.home.icon) }.tag(AppSection.home)
            destination(for: .library).tabItem { Label(AppSection.library.rawValue, systemImage: AppSection.library.icon) }.tag(AppSection.library)
            destination(for: .topics).tabItem { Label(AppSection.topics.rawValue, systemImage: AppSection.topics.icon) }.tag(AppSection.topics)
            destination(for: .saved).tabItem { Label(AppSection.saved.rawValue, systemImage: AppSection.saved.icon) }.tag(AppSection.saved)
        }
    }

    private var splitView: some View {
        NavigationSplitView {
            List(selection: Binding<AppSection?>(
                get: { selectedSection },
                set: { if let section = $0 { selectedSection = section } }
            )) {
                ForEach(AppSection.allCases) { section in
                    Label(section.rawValue, systemImage: section.icon).tag(section)
                }
            }
            .navigationTitle("Catecismo")
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
        case .saved: MyLibraryView()
        }
    }
}

private struct HomeView: View {
    @EnvironmentObject private var library: LibraryViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(colors: [.indigo, .purple.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 88, weight: .light)).foregroundStyle(.white.opacity(0.16))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing).padding(24)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Catecismo").font(.largeTitle.bold())
                            Text("Um caminho de leitura e reflexão.").font(.headline).opacity(0.9)
                        }
                        .foregroundStyle(.white).padding(24)
                    }
                    .frame(height: 210).clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    DisclosureGroup("Sobre este aplicativo") {
                        Text("Aplicativo independente e não oficial. Reúne guias autorais de introdução e não afirma ser o Catecismo completo nem substitui fontes oficiais.")
                            .font(.footnote).foregroundStyle(.secondary).padding(.top, 6)
                    }

                    Text("Comece a ler").font(.title2.bold())
                    if library.guides.isEmpty {
                        ContentUnavailableView("Nenhum guia disponível", systemImage: "books.vertical")
                    } else {
                        ForEach(library.guides.prefix(3)) { guide in GuideRow(guide: guide) }
                    }
                }
                .frame(maxWidth: 760, alignment: .leading).padding()
            }
            .navigationTitle("Início")
        }
    }
}

private struct LibraryView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @State private var query = ""
    private var filtered: [Guide] {
        query.isEmpty ? library.guides : library.guides.filter {
            "\($0.title) \($0.category) \($0.description)".localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    ContentUnavailableView {
                        Label(query.isEmpty ? "Nenhum guia disponível" : "Nenhum resultado", systemImage: query.isEmpty ? "books.vertical" : "magnifyingglass")
                    } description: {
                        Text(query.isEmpty ? "Não há conteúdo para mostrar." : "Tente buscar por outro título ou tema.")
                    }
                } else {
                    List(filtered) { GuideRow(guide: $0) }
                }
            }
            .searchable(text: $query, prompt: "Buscar guia ou tema")
            .navigationTitle("Biblioteca")
        }
    }
}

private struct TopicsView: View {
    @EnvironmentObject private var library: LibraryViewModel
    private var categories: [String] { Array(Set(library.guides.map(\.category))).sorted() }

    var body: some View {
        NavigationStack {
            Group {
                if categories.isEmpty {
                    ContentUnavailableView("Nenhum tema disponível", systemImage: "square.grid.2x2")
                } else {
                    List(categories, id: \.self) { category in
                        Section(category) {
                            ForEach(library.guides.filter { $0.category == category }) { GuideRow(guide: $0) }
                        }
                    }
                }
            }
            .navigationTitle("Temas")
        }
    }
}

private struct MyLibraryView: View {
    @EnvironmentObject private var library: LibraryViewModel
    private var favoriteGuides: [Guide] { library.guides.filter { library.isFavorite($0.id) } }

    var body: some View {
        NavigationStack {
            List {
                Section("Progresso") {
                    LabeledContent("Guias iniciados", value: "\(library.startedGuideCount)")
                    LabeledContent("Tempo estimado", value: "\(library.readingMinutes) min")
                }
                Section("Favoritos") {
                    if favoriteGuides.isEmpty {
                        Label("Seus guias favoritos aparecerão aqui.", systemImage: "heart")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(favoriteGuides) { GuideRow(guide: $0) }
                    }
                }
                Section("Citações") {
                    if library.quotes.isEmpty {
                        Label("As citações salvas aparecerão aqui.", systemImage: "quote.opening")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(library.quotes) { quote in
                            Text("“\(quote.text)”")
                                .accessibilityLabel("Citação salva: \(quote.text)")
                                .swipeActions {
                                    Button(role: .destructive) { library.removeQuote(quote) } label: {
                                        Label("Remover citação", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Minha biblioteca")
        }
    }
}

private struct GuideRow: View {
    @EnvironmentObject private var library: LibraryViewModel
    let guide: Guide

    var body: some View {
        NavigationLink { GuideDetailView(guide: guide) } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(guide.title).font(.headline)
                Text(guide.category).font(.subheadline).foregroundStyle(.secondary)
                if let progress = library.progress[guide.id], progress > 0 {
                    ProgressView(value: progress) {
                        Text("Progresso")
                    } currentValueLabel: {
                        Text(progress, format: .percent.precision(.fractionLength(0)))
                    }
                    .font(.caption)
                }
            }
            .padding(.vertical, 3)
        }
    }
}

private struct GuideDetailView: View {
    @EnvironmentObject private var library: LibraryViewModel
    let guide: Guide
    @StateObject private var speech = SpeechReader()
    @State private var selectedChapter = 0

    private var chapter: Chapter? {
        guard guide.chapters.indices.contains(selectedChapter) else { return nil }
        return guide.chapters[selectedChapter]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(guide.title).font(.largeTitle.bold())
                Text(guide.description).foregroundStyle(.secondary)
                Text("Guia autoral · \(guide.category)").font(.footnote).foregroundStyle(.secondary)
                DisclosureGroup("Contexto") { Text(guide.context).font(.callout).padding(.top, 5) }

                if let chapter {
                    reader(chapter)
                } else {
                    ContentUnavailableView {
                        Label("Guia sem capítulos", systemImage: "doc.text.magnifyingglass")
                    } description: {
                        Text("Este guia ainda não tem conteúdo disponível para leitura.")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: 760, alignment: .leading).padding()
        }
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private func reader(_ chapter: Chapter) -> some View {
        HStack {
            Button {
                speech.isSpeaking ? speech.pause() : speech.isPaused ? speech.resume() : speech.speak(chapter.paragraphs)
            } label: {
                Label(speech.isSpeaking ? "Pausar" : "Ouvir", systemImage: speech.isSpeaking ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.borderedProminent)

            Button { library.toggleFavorite(guide.id) } label: {
                Image(systemName: library.isFavorite(guide.id) ? "heart.fill" : "heart")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(library.isFavorite(guide.id) ? "Remover \(guide.title) dos favoritos" : "Adicionar \(guide.title) aos favoritos")
        }

        Picker("Capítulo", selection: $selectedChapter) {
            ForEach(guide.chapters.indices, id: \.self) { Text(guide.chapters[$0].title).tag($0) }
        }
        .pickerStyle(.menu)

        Text(chapter.title).font(.title2.bold())
        if chapter.paragraphs.isEmpty {
            ContentUnavailableView("Capítulo vazio", systemImage: "doc")
        } else {
            ForEach(Array(chapter.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                HStack(alignment: .top) {
                    Text(paragraph).textSelection(.enabled)
                    Spacer(minLength: 12)
                    Button { library.addQuote(guideID: guide.id, text: paragraph) } label: {
                        Image(systemName: "quote.opening")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Salvar como citação")
                    .accessibilityHint(String(paragraph.prefix(80)))
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
        .padding(.top, 8)
    }
}
