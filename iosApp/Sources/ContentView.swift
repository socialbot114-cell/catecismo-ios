import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var library: LibraryViewModel
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Início", systemImage: "house.fill") }
            LibraryView().tabItem { Label("Biblioteca", systemImage: "books.vertical.fill") }
            TopicsView().tabItem { Label("Temas", systemImage: "square.grid.2x2.fill") }
            MyLibraryView().tabItem { Label("Minha biblioteca", systemImage: "bookmark.fill") }
        }.tint(.indigo)
    }
}

private struct HomeView: View {
    @EnvironmentObject private var library: LibraryViewModel
    var body: some View {
        NavigationStack { ScrollView { VStack(alignment: .leading, spacing: 18) {
            Image("catecismo-start").resizable().scaledToFill().frame(height: 180).clipped().clipShape(RoundedRectangle(cornerRadius: 22))
            Text("Catecismo").font(.largeTitle.bold())
            Text("Um caminho de leitura e reflexão.").foregroundStyle(.secondary)
            DisclosureGroup("Sobre este aplicativo") { Text("Aplicativo independente e não oficial. Reúne guias autorais de introdução e não afirma ser o Catecismo completo nem substitui fontes oficiais.").font(.footnote).foregroundStyle(.secondary).padding(.top, 6) }
            Text("Continue lendo").font(.title2.bold())
            ForEach(library.guides.prefix(3)) { guide in GuideRow(guide: guide) }
        }.padding() }.navigationTitle("Início") }
    }
}

private struct LibraryView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @State private var query = ""
    private var filtered: [Guide] { query.isEmpty ? library.guides : library.guides.filter { "\($0.title) \($0.category) \($0.description)".localizedCaseInsensitiveContains(query) } }
    var body: some View { NavigationStack { List(filtered) { GuideRow(guide: $0) }.searchable(text: $query, prompt: "Buscar guia ou tema").navigationTitle("Biblioteca") } }
}

private struct TopicsView: View {
    @EnvironmentObject private var library: LibraryViewModel
    private var categories: [String] { Array(Set(library.guides.map(\.category))).sorted() }
    var body: some View { NavigationStack { List(categories, id: \.self) { category in Section(category) { ForEach(library.guides.filter { $0.category == category }) { GuideRow(guide: $0) } } }.navigationTitle("Temas") } }
}

private struct MyLibraryView: View {
    @EnvironmentObject private var library: LibraryViewModel
    var body: some View { NavigationStack { List { Section("Progresso") { Text("Guias iniciados: \(library.progress.count)"); Text("Tempo estimado: \(library.readingMinutes) min") }; Section("Favoritos") { ForEach(library.guides.filter { library.isFavorite($0.id) }) { GuideRow(guide: $0) } }; Section("Citações") { ForEach(library.quotes) { quote in Text("“\(quote.text)”").swipeActions { Button(role: .destructive) { library.removeQuote(quote) } label: { Label("Remover", systemImage: "trash") } } } } }.navigationTitle("Minha biblioteca") } }
}

private struct GuideRow: View {
    @EnvironmentObject private var library: LibraryViewModel
    let guide: Guide
    var body: some View { NavigationLink { GuideDetailView(guide: guide) } label: { VStack(alignment: .leading, spacing: 5) { Text(guide.title).font(.headline); Text(guide.category).font(.subheadline).foregroundStyle(.secondary); if let progress = library.progress[guide.id], progress > 0 { ProgressView(value: progress) } } } }
}

private struct GuideDetailView: View {
    @EnvironmentObject private var library: LibraryViewModel
    let guide: Guide
    @StateObject private var speech = SpeechReader()
    @State private var selectedChapter = 0
    private var chapter: Chapter { guide.chapters[selectedChapter] }
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 16) {
        Text(guide.title).font(.largeTitle.bold()); Text(guide.description).foregroundStyle(.secondary); Text("Guia autoral · \(guide.category)").font(.footnote).foregroundStyle(.secondary)
        DisclosureGroup("Contexto") { Text(guide.context).font(.callout).padding(.top, 5) }
        HStack { Button { speech.isSpeaking ? speech.pause() : speech.isPaused ? speech.resume() : speech.speak(chapter.paragraphs) } label: { Label(speech.isSpeaking ? "Pausar" : "Ouvir", systemImage: speech.isSpeaking ? "pause.fill" : "play.fill") }.buttonStyle(.borderedProminent); Button { library.toggleFavorite(guide.id) } label: { Image(systemName: library.isFavorite(guide.id) ? "heart.fill" : "heart") }.buttonStyle(.bordered) }
        Picker("Capítulo", selection: $selectedChapter) { ForEach(guide.chapters.indices, id: \.self) { Text(guide.chapters[$0].title).tag($0) } }.pickerStyle(.menu)
        Text(chapter.title).font(.title2.bold())
        ForEach(chapter.paragraphs, id: \.self) { paragraph in HStack(alignment: .top) { Text(paragraph).textSelection(.enabled); Spacer(); Button { library.addQuote(guideID: guide.id, text: paragraph) } label: { Image(systemName: "quote.opening") }.buttonStyle(.plain) } }
    }.padding() }.navigationTitle(guide.title).navigationBarTitleDisplayMode(.inline).onAppear { updateProgress() }.onChange(of: selectedChapter) { _, _ in updateProgress() } }
    private func updateProgress() { library.setProgress(Double(selectedChapter + 1) / Double(guide.chapterCount), for: guide.id) }
}
