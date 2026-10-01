import Foundation

struct SearchHit: Identifiable, Hashable {
    let guideID: String
    let chapterIndex: Int
    let paragraphIndex: Int
    let chapterTitle: String
    let snippet: String
    var id: String { "\(guideID)#\(chapterIndex)#\(paragraphIndex)" }
}

struct LibrarySearchResults: Equatable {
    var guideIDs: [String] = []
    var hits: [SearchHit] = []
    var truncated = false
    var isEmpty: Bool { guideIDs.isEmpty && hits.isEmpty }
}

/// Precomputed, accent- and case-folded text so each search is a plain substring scan.
struct LibrarySearchIndex {
    private struct Entry {
        let guideID: String
        let chapterIndex: Int
        let paragraphIndex: Int
        let folded: String
    }

    private let guideMetadata: [(id: String, folded: String)]
    private let entries: [Entry]
    private let chapterTitles: [String: [String]]
    private let paragraphs: [String: [[String]]]
    private let catechismNumbers: [Int: (guideID: String, chapter: Int, paragraph: Int)]
    static let maxHits = 60

    init(guides: [Guide]) {
        var metadata: [(id: String, folded: String)] = []
        var entries: [Entry] = []
        var titles: [String: [String]] = [:]
        var paragraphs: [String: [[String]]] = [:]
        var numbers: [Int: (guideID: String, chapter: Int, paragraph: Int)] = [:]
        for guide in guides {
            let chapterTitlesText = guide.chapters.map(\.title).joined(separator: " ")
            metadata.append((id: guide.id, folded: Self.fold("\(guide.title) \(guide.category) \(guide.description) \(guide.context) \(chapterTitlesText)")))
            titles[guide.id] = guide.chapters.map(\.title)
            paragraphs[guide.id] = guide.chapters.map(\.paragraphs)
            for (chapterIndex, chapter) in guide.chapters.enumerated() {
                for (paragraphIndex, paragraph) in chapter.paragraphs.enumerated() {
                    entries.append(Entry(guideID: guide.id, chapterIndex: chapterIndex, paragraphIndex: paragraphIndex, folded: Self.fold(paragraph)))
                    if guide.isCatechism, let number = Self.catechismNumber(of: paragraph), numbers[number] == nil {
                        numbers[number] = (guideID: guide.id, chapter: chapterIndex, paragraph: paragraphIndex)
                    }
                }
            }
        }
        guideMetadata = metadata
        self.entries = entries
        chapterTitles = titles
        self.paragraphs = paragraphs
        catechismNumbers = numbers
    }

    static func fold(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
    }

    /// Leading "1234." number of a Catechism paragraph.
    static func catechismNumber(of paragraph: String) -> Int? {
        guard let prefix = paragraph.split(separator: ".", maxSplits: 1).first, prefix.count <= 4 else { return nil }
        return Int(prefix)
    }

    /// "§1234", "§ 1234", "1234" or "n. 1234" jump straight to that Catechism paragraph.
    static func requestedParagraphNumber(in query: String) -> Int? {
        var text = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        for prefix in ["§§", "§", "n.", "n°", "nº", "#"] where text.hasPrefix(prefix) {
            text = String(text.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
            break
        }
        guard (1...4).contains(text.count), text.allSatisfy(\.isNumber) else { return nil }
        return Int(text)
    }

    func search(_ query: String) -> LibrarySearchResults {
        let term = Self.fold(query.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !term.isEmpty else { return LibrarySearchResults() }
        var results = LibrarySearchResults()

        if let number = Self.requestedParagraphNumber(in: query), let location = catechismNumbers[number] {
            results.hits.append(hit(guideID: location.guideID, chapter: location.chapter, paragraph: location.paragraph, term: nil))
        }

        var matchedGuides = Set<String>()
        for entry in guideMetadata where entry.folded.contains(term) {
            matchedGuides.insert(entry.id)
        }
        guard term.count >= 2 else {
            results.guideIDs = guideMetadata.map(\.id).filter(matchedGuides.contains)
            return results
        }
        for entry in entries where entry.folded.contains(term) {
            matchedGuides.insert(entry.guideID)
            if results.hits.count < Self.maxHits {
                let candidate = hit(guideID: entry.guideID, chapter: entry.chapterIndex, paragraph: entry.paragraphIndex, term: term)
                if !results.hits.contains(where: { $0.id == candidate.id }) { results.hits.append(candidate) }
            } else {
                results.truncated = true
            }
        }
        results.guideIDs = guideMetadata.map(\.id).filter(matchedGuides.contains)
        return results
    }

    private func hit(guideID: String, chapter: Int, paragraph: Int, term: String?) -> SearchHit {
        let text = paragraphs[guideID]?[chapter][paragraph] ?? ""
        return SearchHit(
            guideID: guideID,
            chapterIndex: chapter,
            paragraphIndex: paragraph,
            chapterTitle: chapterTitles[guideID]?[chapter] ?? "",
            snippet: Self.snippet(of: text, around: term)
        )
    }

    /// A short excerpt centered on the first match, so the reader sees why the paragraph was found.
    static func snippet(of text: String, around term: String?, radius: Int = 90) -> String {
        guard let term, !term.isEmpty,
              let range = text.range(of: term, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) else {
            return text.count > radius * 2 ? String(text.prefix(radius * 2)) + "…" : text
        }
        let start = text.index(range.lowerBound, offsetBy: -radius, limitedBy: text.startIndex) ?? text.startIndex
        let end = text.index(range.upperBound, offsetBy: radius, limitedBy: text.endIndex) ?? text.endIndex
        var excerpt = String(text[start..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
        if start > text.startIndex { excerpt = "…" + excerpt }
        if end < text.endIndex { excerpt += "…" }
        return excerpt
    }
}
