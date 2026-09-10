import Foundation

struct WorkSummary: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let description: String
    let year: Int
    let chapters: Int
    let words: Int
    let sourceURL: String
}

final class LibraryViewModel: ObservableObject {
    @Published var works: [WorkSummary] = []
    @Published var progress: [String: Double] = [:]

    init() {
        works = loadCatalog()
    }

    var readingMinutes: Int { 0 }

    private func loadCatalog() -> [WorkSummary] {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([CatalogEntry].self, from: data) else {
            return []
        }
        return entries.map {
            WorkSummary(id: $0.id, title: $0.title, category: $0.category, description: $0.description,
                        year: $0.year, chapters: $0.chapters, words: $0.words, sourceURL: $0.sourceUrl)
        }
    }
}

private struct CatalogEntry: Decodable {
    let id: String
    let title: String
    let year: Int
    let category: String
    let description: String
    let sourceUrl: String
    let chapters: Int
    let words: Int
}
