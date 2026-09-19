import Foundation
import Combine

struct Guide: Codable, Identifiable, Hashable {
    let id: String; let title: String; let author: String; let year: Int
    let category: String; let description: String; let context: String
    let chapters: [Chapter]; let sourceURL: String
    var chapterCount: Int { chapters.count }
    var paragraphCount: Int { chapters.reduce(0) { $0 + $1.paragraphs.count } }
    enum CodingKeys: String, CodingKey { case id, title, author, year, category, description, context, chapters, sourceURL = "sourceUrl" }
}

struct Chapter: Codable, Hashable { let title: String; let paragraphs: [String] }
struct Quote: Codable, Hashable, Identifiable { let id: String; let guideID: String; let text: String; let date: Date }

enum LibraryLoadState: Equatable {
    case loading
    case loaded
    case failed(String)
}

final class LibraryViewModel: ObservableObject {
    @Published private(set) var guides: [Guide] = []
    @Published private(set) var progress: [String: Double] = [:]
    @Published private(set) var favorites: Set<String> = []
    @Published private(set) var quotes: [Quote] = []
    @Published private(set) var loadState = LibraryLoadState.loading
    private let defaults: UserDefaults
    private let repository: BundleGuideRepository

    init(defaults: UserDefaults = .standard, repository: BundleGuideRepository = BundleGuideRepository()) {
        self.defaults = defaults
        self.repository = repository
    }
    var readingMinutes: Int { Int(progress.values.reduce(0, +) * 12) }
    var startedGuideCount: Int { progress.values.filter { $0 > 0 }.count }
    func isFavorite(_ id: String) -> Bool { favorites.contains(id) }
    func toggleFavorite(_ id: String) { favorites.formSymmetricDifference([id]); save() }
    func setProgress(_ value: Double, for id: String) {
        let normalized = min(max(value, 0), 1)
        if normalized == 0 { progress.removeValue(forKey: id) } else { progress[id] = normalized }
        save()
    }
    func completeChapter(at index: Int, in guide: Guide) {
        guard let value = Self.progress(completingChapterAt: index, chapterCount: guide.chapterCount) else { return }
        setProgress(max(progress[guide.id] ?? 0, value), for: guide.id)
    }
    static func progress(completingChapterAt index: Int, chapterCount: Int) -> Double? {
        guard chapterCount > 0, (0..<chapterCount).contains(index) else { return nil }
        return Double(index + 1) / Double(chapterCount)
    }
    func addQuote(guideID: String, text: String) { quotes.append(Quote(id: UUID().uuidString, guideID: guideID, text: text, date: Date())); save() }
    func removeQuote(_ quote: Quote) { quotes.removeAll { $0.id == quote.id }; save() }

    func load() {
        loadState = .loading
        do {
            guides = try repository.loadGuides()
            progress = ((defaults.dictionary(forKey: "catecismo.progress") as? [String: Double]) ?? [:])
                .compactMapValues { value in value > 0 ? min(value, 1) : nil }
            favorites = Set(defaults.stringArray(forKey: "catecismo.favorites") ?? [])
            if let data = defaults.data(forKey: "catecismo.quotes") {
                quotes = (try? JSONDecoder().decode([Quote].self, from: data)) ?? []
            }
            loadState = .loaded
        } catch {
            guides = []
            loadState = .failed(error.localizedDescription)
        }
    }
    private func save() {
        defaults.set(progress, forKey: "catecismo.progress")
        defaults.set(Array(favorites), forKey: "catecismo.favorites")
        if let data = try? JSONEncoder().encode(quotes) { defaults.set(data, forKey: "catecismo.quotes") }
    }
}

final class BundleGuideRepository {
    private let guideIDs = ["o-dom-da-fe", "credo-em-caminho", "sinais-da-graca", "liberdade-e-amor", "escola-da-oracao", "a-igreja-viva", "maria-e-o-sim", "conversao-diaria"]
    func loadGuides() throws -> [Guide] {
        try guideIDs.map { try JSONDecoder().decode(Guide.self, from: BundleResource.data(named: $0, fileExtension: "json", subdirectory: "Texts")) }
    }
}

enum BundleResource {
    static func data(named name: String, fileExtension: String, subdirectory: String? = nil) throws -> Data {
        let bundles = [Bundle.main] + Bundle.allFrameworks + Bundle.allBundles
        let rootURLs = bundles.compactMap { bundle in
            bundle.url(forResource: name, withExtension: fileExtension)
        }
        let directories = [subdirectory, "Resources", "Resources/Texts"].compactMap { $0 }
        let urls = rootURLs + bundles.flatMap { bundle in
            directories.compactMap { directory in
                bundle.url(forResource: name, withExtension: fileExtension, subdirectory: directory)
            }
        }
        guard let url = urls.first else { throw BundleResourceError.missing(name) }
        do { return try Data(contentsOf: url) }
        catch { throw BundleResourceError.read(name, error.localizedDescription) }
    }
}

enum BundleResourceError: LocalizedError {
    case missing(String)
    case read(String, String)
    case invalid(String)

    var errorDescription: String? {
        switch self {
        case .missing(let name): return "Recurso offline não encontrado: \(name).json"
        case .read(let name, let detail): return "Não foi possível ler \(name).json: \(detail)"
        case .invalid(let detail): return detail
        }
    }
}
