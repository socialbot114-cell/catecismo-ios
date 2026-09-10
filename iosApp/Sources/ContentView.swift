import SwiftUI

struct ContentView: View {
    @StateObject private var library = LibraryViewModel()

    var body: some View {
        TabView {
            HomeView(library: library)
                .tabItem { Label("Início", systemImage: "house.fill") }
            LibraryView(library: library)
                .tabItem { Label("Biblioteca", systemImage: "books.vertical.fill") }
            UniverseView()
                .tabItem { Label("Universo", systemImage: "person.3.fill") }
            MyLibraryView(library: library)
                .tabItem { Label("Minha Biblioteca", systemImage: "bookmark.fill") }
        }
        .tint(Color(red: 0.45, green: 0.20, blue: 0.12))
    }
}

private struct HomeView: View {
    @ObservedObject var library: LibraryViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Biblioteca Machado de Assis").font(.largeTitle.bold())
                    Text("Leia offline. Ouça com a tela bloqueada. Descubra um clássico por vez.")
                        .foregroundStyle(.secondary)
                    if let work = library.works.first {
                        NavigationLink(value: work) { FeaturedWorkCard(work: work) }
                            .buttonStyle(.plain)
                    }
                    Text("Continue lendo").font(.title2.bold())
                    ForEach(library.works.prefix(3)) { work in WorkRow(work: work) }
                }
                .padding()
            }
            .navigationTitle("Início")
            .navigationDestination(for: WorkSummary.self) { work in ReaderView(work: work) }
        }
    }
}

private struct LibraryView: View {
    @ObservedObject var library: LibraryViewModel
    @State private var query = ""

    private var filteredWorks: [WorkSummary] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return library.works }
        return library.works.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(filteredWorks) { work in
                NavigationLink(value: work) { WorkRow(work: work) }
            }
            .searchable(text: $query, prompt: "Buscar obra")
            .navigationTitle("Biblioteca")
            .navigationDestination(for: WorkSummary.self) { work in ReaderView(work: work) }
        }
    }
}

private struct UniverseView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "person.3.fill").font(.largeTitle)
                Text("Universo Machado").font(.title2.bold())
                Text("Personagens e linha do tempo serão carregados do catálogo compartilhado.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Universo")
        }
    }
}

private struct MyLibraryView: View {
    @ObservedObject var library: LibraryViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Leitura") {
                    Label("Obras iniciadas: \(library.progress.count)", systemImage: "book")
                    Label("Tempo de leitura: \(library.readingMinutes) min", systemImage: "clock")
                }
                Section("Privacidade") {
                    Text("Seu progresso fica somente neste aparelho.").foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Minha Biblioteca")
        }
    }
}

private struct FeaturedWorkCard: View {
    let work: WorkSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
                    Text(work.title).font(.title.bold())
                    Text(work.description).lineLimit(3).foregroundStyle(.secondary)
                    Text("\(work.chapters) capítulos · \(work.words.formatted()) palavras")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
            Label("Ler offline", systemImage: "arrow.down.circle").font(.subheadline.weight(.semibold))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.brown.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct WorkRow: View {
    let work: WorkSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(work.title).font(.headline)
            Text(work.category.capitalized).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct ReaderView: View {
    let work: WorkSummary
    @StateObject private var speech = SpeechReader()
    @State private var paragraphs: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(work.title).font(.largeTitle.bold())
                Text(work.description).foregroundStyle(.secondary)
                Text("\(work.chapters) capítulos · \(work.words.formatted()) palavras")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Fonte: Wikisource PT")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if paragraphs.isEmpty {
                    ProgressView("Carregando capítulo offline…")
                } else {
                    ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                        Text(paragraph)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                }
                Button(speech.isSpeaking ? "Pausar narração" : "Ouvir capítulo") {
                    speech.isSpeaking ? speech.pause() : speech.speak(paragraphs.joined(separator: " "))
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle(work.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { paragraphs = loadFirstChapter(for: work.id) }
    }

    private func loadFirstChapter(for id: String) -> [String] {
        guard let url = Bundle.main.url(forResource: id, withExtension: "json", subdirectory: "Texts"),
              let data = try? Data(contentsOf: url),
              let document = try? JSONDecoder().decode(WorkDocument.self, from: data) else {
            return []
        }
        return document.chapters.first?.paragraphs ?? []
    }
}

private struct WorkDocument: Decodable {
    let chapters: [DocumentChapter]
}

private struct DocumentChapter: Decodable {
    let paragraphs: [String]
}
