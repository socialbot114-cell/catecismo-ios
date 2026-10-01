import Foundation
import Combine

struct Guide: Codable, Identifiable, Hashable {
    let id: String; let title: String; let author: String; let year: Int
    let category: String; let description: String; let context: String
    let chapters: [Chapter]; let sourceURL: String
    /// Language of the bundled text. The Catechism parts are always Portuguese, even when the UI is not.
    var contentLanguage: String = "pt-BR"
    var chapterCount: Int { chapters.count }
    var paragraphCount: Int { chapters.reduce(0) { $0 + $1.paragraphs.count } }
    var isCatechism: Bool { category == Self.catechismCategory }
    /// Progress and reading position are stored per text edition, because translated guides have a different chapter count.
    var storageKey: String { contentLanguage == "pt-BR" ? id : "\(id)@\(contentLanguage)" }
    static let catechismCategory = "Catecismo"
    enum CodingKeys: String, CodingKey { case id, title, author, year, category, description, context, chapters, sourceURL = "sourceUrl" }
}

struct Chapter: Codable, Hashable { let title: String; let paragraphs: [String] }

struct Quote: Codable, Hashable, Identifiable {
    let id: String; let guideID: String; let text: String; let date: Date
    var chapterIndex: Int? = nil
    var paragraphIndex: Int? = nil
}

struct ReadingPosition: Codable, Hashable {
    var chapter: Int
    var paragraph: Int
}

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
    @Published private(set) var positions: [String: ReadingPosition] = [:]
    @Published private(set) var readingSeconds: TimeInterval = 0
    @Published private(set) var lastReadKey: String?
    /// Incremented whenever a new set of guides is loaded (for example after a language change).
    @Published private(set) var contentVersion = 0
    @Published private(set) var loadState = LibraryLoadState.loading
    private(set) var searchIndex = LibrarySearchIndex(guides: [])
    private let defaults: UserDefaults
    private let repository: BundleGuideRepository
    private var loadGeneration = 0

    private enum Keys {
        static let progress = "catecismo.progress"
        static let favorites = "catecismo.favorites"
        static let quotes = "catecismo.quotes"
        static let positions = "catecismo.positions"
        static let readingSeconds = "catecismo.readingSeconds"
        static let lastRead = "catecismo.lastRead"
    }

    init(defaults: UserDefaults = .standard, repository: BundleGuideRepository = BundleGuideRepository()) {
        self.defaults = defaults
        self.repository = repository
        restoreUserData()
    }

    var readingMinutes: Int { Int(readingSeconds / 60) }
    var startedGuideCount: Int { progress.values.filter { $0 > 0 }.count }
    func guide(withID id: String) -> Guide? { guides.first { $0.id == id } }
    func completion(for guide: Guide) -> Double { progress[guide.storageKey] ?? 0 }

    func isFavorite(_ id: String) -> Bool { favorites.contains(id) }
    func toggleFavorite(_ id: String) { favorites.formSymmetricDifference([id]); save() }

    func setProgress(_ value: Double, for key: String) {
        let normalized = min(max(value, 0), 1)
        if normalized == 0 { progress.removeValue(forKey: key) } else { progress[key] = normalized }
        save()
    }
    func completeChapter(at index: Int, in guide: Guide) {
        guard let value = Self.progress(completingChapterAt: index, chapterCount: guide.chapterCount) else { return }
        setProgress(max(progress[guide.storageKey] ?? 0, value), for: guide.storageKey)
    }
    static func progress(completingChapterAt index: Int, chapterCount: Int) -> Double? {
        guard chapterCount > 0, (0..<chapterCount).contains(index) else { return nil }
        return Double(index + 1) / Double(chapterCount)
    }

    /// The guide the reader opened most recently, falling back to any guide that is started but not finished.
    var continueReadingGuide: Guide? {
        if let lastReadKey, let guide = guides.first(where: { $0.storageKey == lastReadKey }), completion(for: guide) < 1 {
            return guide
        }
        return guides.first { (progress[$0.storageKey] ?? 0) > 0 && (progress[$0.storageKey] ?? 0) < 1 }
    }

    func position(for guide: Guide) -> ReadingPosition? {
        guard let position = positions[guide.storageKey], guide.chapters.indices.contains(position.chapter) else { return nil }
        let paragraphCount = guide.chapters[position.chapter].paragraphs.count
        return ReadingPosition(chapter: position.chapter, paragraph: min(max(position.paragraph, 0), max(paragraphCount - 1, 0)))
    }
    func savePosition(_ position: ReadingPosition, for guide: Guide) {
        guard guide.chapters.indices.contains(position.chapter) else { return }
        guard positions[guide.storageKey] != position || lastReadKey != guide.storageKey else { return }
        positions[guide.storageKey] = position
        lastReadKey = guide.storageKey
        save()
    }

    /// Adds wall-clock time spent in the reader. Long idle sessions are capped so a forgotten open screen does not inflate the total.
    func addReadingTime(_ seconds: TimeInterval) {
        guard seconds >= 1 else { return }
        readingSeconds += min(seconds, 2 * 60 * 60)
        save()
    }

    func hasQuote(guideID: String, text: String) -> Bool { quotes.contains { $0.guideID == guideID && $0.text == text } }
    /// Returns false when the same passage was already saved.
    @discardableResult
    func addQuote(guideID: String, text: String, chapterIndex: Int? = nil, paragraphIndex: Int? = nil) -> Bool {
        guard !hasQuote(guideID: guideID, text: text) else { return false }
        quotes.append(Quote(id: UUID().uuidString, guideID: guideID, text: text, date: Date(), chapterIndex: chapterIndex, paragraphIndex: paragraphIndex))
        save()
        return true
    }
    func removeQuote(_ quote: Quote) { quotes.removeAll { $0.id == quote.id }; save() }

    /// Decodes the bundled texts off the main thread; only the latest request is applied.
    func load(languageCode: String = "pt-BR") {
        loadGeneration += 1
        let generation = loadGeneration
        if guides.isEmpty { loadState = .loading }
        let repository = repository
        DispatchQueue.global(qos: .userInitiated).async {
            let result = Result { try repository.loadGuides(languageCode: languageCode) }
            let index = (try? result.get()).map(LibrarySearchIndex.init(guides:))
            DispatchQueue.main.async { [weak self] in
                guard let self, generation == self.loadGeneration else { return }
                switch result {
                case .success(let guides):
                    self.guides = guides
                    self.searchIndex = index ?? LibrarySearchIndex(guides: guides)
                    self.contentVersion += 1
                    self.loadState = .loaded
                case .failure(let error):
                    self.guides = []
                    self.searchIndex = LibrarySearchIndex(guides: [])
                    self.loadState = .failed(error.localizedDescription)
                }
            }
        }
    }

    private func restoreUserData() {
        progress = ((defaults.dictionary(forKey: Keys.progress) as? [String: Double]) ?? [:])
            .compactMapValues { value in value > 0 ? min(value, 1) : nil }
        favorites = Set(defaults.stringArray(forKey: Keys.favorites) ?? [])
        if let data = defaults.data(forKey: Keys.quotes) {
            quotes = (try? JSONDecoder().decode([Quote].self, from: data)) ?? []
        }
        if let data = defaults.data(forKey: Keys.positions) {
            positions = (try? JSONDecoder().decode([String: ReadingPosition].self, from: data)) ?? [:]
        }
        readingSeconds = max(defaults.double(forKey: Keys.readingSeconds), 0)
        lastReadKey = defaults.string(forKey: Keys.lastRead)
    }

    private func save() {
        defaults.set(progress, forKey: Keys.progress)
        defaults.set(Array(favorites), forKey: Keys.favorites)
        if let data = try? JSONEncoder().encode(quotes) { defaults.set(data, forKey: Keys.quotes) }
        if let data = try? JSONEncoder().encode(positions) { defaults.set(data, forKey: Keys.positions) }
        defaults.set(readingSeconds, forKey: Keys.readingSeconds)
        defaults.set(lastReadKey, forKey: Keys.lastRead)
    }
}

final class BundleGuideRepository {
    private let guideIDs = ["o-dom-da-fe", "credo-em-caminho", "sinais-da-graca", "liberdade-e-amor", "escola-da-oracao", "a-igreja-viva", "maria-e-o-sim", "conversao-diaria"]
    private let catechismIDs = ["catecismo-parte-1", "catecismo-parte-2", "catecismo-parte-3", "catecismo-parte-4"]
    private let lock = NSLock()
    private var cachedCatechism: [Guide]?

    func loadGuides(languageCode: String = "pt-BR") throws -> [Guide] {
        let catechism = try catechismParts()
        if languageCode != "pt-BR",
           let data = try? BundleResource.data(named: languageCode, fileExtension: "json", subdirectory: "Texts"),
           let translated = try? JSONDecoder().decode([Guide].self, from: data) {
            return translated.map { guide in
                var guide = guide
                guide.contentLanguage = languageCode
                return guide
            } + catechism
        }
        let authored = try guideIDs.map {
            try JSONDecoder().decode(Guide.self, from: BundleResource.data(named: $0, fileExtension: "json", subdirectory: "Texts"))
        }
        return authored + catechism
    }

    /// The Portuguese Catechism is identical for every UI language, so it is decoded only once.
    private func catechismParts() throws -> [Guide] {
        lock.lock()
        defer { lock.unlock() }
        if let cachedCatechism { return cachedCatechism }
        let parts = try catechismIDs.map {
            try JSONDecoder().decode(Guide.self, from: BundleResource.data(named: $0, fileExtension: "json", subdirectory: "Texts"))
        }
        cachedCatechism = parts
        return parts
    }
}

enum BundleResource {
    static func data(named name: String, fileExtension: String, subdirectory: String? = nil, bundle: Bundle = .main) throws -> Data {
        let candidates = [subdirectory, "Resources/Texts", nil]
        let url = candidates.lazy.compactMap { bundle.url(forResource: name, withExtension: fileExtension, subdirectory: $0) }.first
        guard let url else { throw BundleResourceError.missing(name) }
        do { return try Data(contentsOf: url) }
        catch { throw BundleResourceError.read(name, error.localizedDescription) }
    }
}

enum BundleResourceError: LocalizedError {
    case missing(String)
    case read(String, String)

    var errorDescription: String? {
        switch self {
        case .missing(let name): return "Recurso offline não encontrado: \(name).json"
        case .read(let name, let detail): return "Não foi possível ler \(name).json: \(detail)"
        }
    }
}
