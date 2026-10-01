import AVFoundation
import Combine
import XCTest
@testable import Catecismo

final class CatecismoTests: XCTestCase {
    func testGuideDecodesStableLocalShape() throws {
        let json = #"{"id":"teste","title":"Guia","author":"Equipe","year":2026,"category":"Tema","description":"Resumo","context":"Contexto","sourceUrl":"https://example.invalid","chapters":[{"title":"Começo","paragraphs":["Texto"]}]}"#.data(using: .utf8)!
        let guide = try JSONDecoder().decode(Guide.self, from: json)
        XCTAssertEqual(guide.id, "teste")
        XCTAssertEqual(guide.chapterCount, 1)
        XCTAssertEqual(guide.paragraphCount, 1)
    }

    func testQuoteIsPersistable() throws {
        let quote = Quote(id: "q", guideID: "guia", text: "Uma frase", date: Date(timeIntervalSince1970: 0))
        let decoded = try JSONDecoder().decode(Quote.self, from: JSONEncoder().encode(quote))
        XCTAssertEqual(decoded, quote)
    }

    func testAllPackagedGuidesDecode() throws {
        let guides = try BundleGuideRepository().loadGuides()
        XCTAssertEqual(guides.count, 12)
        XCTAssertTrue(guides.allSatisfy { !$0.id.isEmpty && !$0.chapters.isEmpty })
        XCTAssertEqual(guides.filter { $0.category == "Catecismo" }.count, 4)
    }

    func testAppLanguageMapsDeviceRegionToSupportedContentBundle() {
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "en-GB")), "en")
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "es-MX")), "es")
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "fr-CA")), "fr")
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "pt-PT")), "pt-BR")
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "de-DE")), "pt-BR")
    }

    func testLocalizedGuideBundlesKeepGuideIDsAndAppendCatechismParts() throws {
        let repository = BundleGuideRepository()
        let baseGuides = try repository.loadGuides(languageCode: "pt-BR")
        let authoredIDs = Set(baseGuides.filter { $0.category != "Catecismo" }.map(\.id))
        let catechismIDs = Set(baseGuides.filter { $0.category == "Catecismo" }.map(\.id))

        for language in ["en", "es", "fr"] {
            let translated = try repository.loadGuides(languageCode: language)
            XCTAssertEqual(Set(translated.filter { $0.category != "Catecismo" }.map(\.id)), authoredIDs, "Missing translated guide IDs for \(language)")
            XCTAssertEqual(Set(translated.filter { $0.category == "Catecismo" }.map(\.id)), catechismIDs, "Missing official Catechism parts for \(language)")
            XCTAssertEqual(
                translated.filter { $0.category == "Catecismo" },
                baseGuides.filter { $0.category == "Catecismo" },
                "The bundled Portuguese Catechism parts should remain unchanged in \(language)"
            )
        }
    }

    func testOpeningGuideDoesNotCreateProgress() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let library = LibraryViewModel(defaults: defaults)

        XCTAssertEqual(library.startedGuideCount, 0)
        XCTAssertTrue(library.progress.isEmpty)
    }

    func testProgressOnlyChangesWhenChapterIsCompleted() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let library = LibraryViewModel(defaults: defaults)
        let guide = makeGuide(chapterCount: 2)

        library.completeChapter(at: 0, in: guide)

        XCTAssertEqual(library.progress[guide.id], 0.5)
        XCTAssertEqual(library.startedGuideCount, 1)
    }

    func testEmptyGuideCannotCreateProgress() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let library = LibraryViewModel(defaults: defaults)

        library.completeChapter(at: 0, in: makeGuide(chapterCount: 0))

        XCTAssertTrue(library.progress.isEmpty)
        XCTAssertNil(LibraryViewModel.progress(completingChapterAt: 0, chapterCount: 0))
    }

    func testTranslatedGuidesKeepPortugueseCatechismLanguage() throws {
        let guides = try BundleGuideRepository().loadGuides(languageCode: "en")
        XCTAssertTrue(guides.filter { !$0.isCatechism }.allSatisfy { $0.contentLanguage == "en" })
        XCTAssertTrue(guides.filter(\.isCatechism).allSatisfy { $0.contentLanguage == "pt-BR" })
        XCTAssertEqual(guides.filter(\.isCatechism).first?.storageKey, "catecismo-parte-1")
    }

    func testProgressIsTrackedPerTextEdition() {
        let defaults = freshDefaults(#function)
        let library = LibraryViewModel(defaults: defaults)
        let portuguese = makeGuide(chapterCount: 6)
        var english = makeGuide(chapterCount: 2)
        english.contentLanguage = "en"

        library.completeChapter(at: 1, in: english)

        XCTAssertEqual(library.completion(for: english), 1)
        XCTAssertEqual(library.completion(for: portuguese), 0)
    }

    func testReadingPositionPersistsAndIsClamped() {
        let defaults = freshDefaults(#function)
        let guide = makeGuide(chapterCount: 3)
        LibraryViewModel(defaults: defaults).savePosition(ReadingPosition(chapter: 2, paragraph: 40), for: guide)

        let restored = LibraryViewModel(defaults: defaults)
        XCTAssertEqual(restored.position(for: guide), ReadingPosition(chapter: 2, paragraph: 0))
        XCTAssertEqual(restored.lastReadKey, guide.storageKey)
        restored.savePosition(ReadingPosition(chapter: 9, paragraph: 0), for: guide)
        XCTAssertEqual(restored.position(for: guide)?.chapter, 2)
    }

    func testQuotesAreNotDuplicatedAndKeepTheirLocation() {
        let library = LibraryViewModel(defaults: freshDefaults(#function))
        XCTAssertTrue(library.addQuote(guideID: "teste", text: "Texto", chapterIndex: 1, paragraphIndex: 0))
        XCTAssertFalse(library.addQuote(guideID: "teste", text: "Texto", chapterIndex: 1, paragraphIndex: 0))
        XCTAssertEqual(library.quotes.count, 1)
        XCTAssertEqual(library.quotes.first?.chapterIndex, 1)
    }

    func testQuotesSavedByEarlierVersionsStillDecode() throws {
        let json = #"[{"id":"q","guideID":"guia","text":"Uma frase","date":0}]"#.data(using: .utf8)!
        let quotes = try JSONDecoder().decode([Quote].self, from: json)
        XCTAssertEqual(quotes.first?.text, "Uma frase")
        XCTAssertNil(quotes.first?.chapterIndex)
    }

    func testReadingTimeIsMeasuredAndCapped() {
        let defaults = freshDefaults(#function)
        let library = LibraryViewModel(defaults: defaults)
        library.addReadingTime(150)
        library.addReadingTime(0.2)
        XCTAssertEqual(library.readingMinutes, 2)
        library.addReadingTime(24 * 60 * 60)
        XCTAssertEqual(LibraryViewModel(defaults: defaults).readingMinutes, 2 + 120)
    }

    func testLoadPublishesGuidesAsynchronously() {
        let library = LibraryViewModel(defaults: freshDefaults(#function))
        let loaded = expectation(description: "guides loaded")
        let cancellable = library.$loadState.sink { state in
            if state == .loaded { loaded.fulfill() }
        }
        library.load(languageCode: "pt-BR")
        wait(for: [loaded], timeout: 20)
        cancellable.cancel()
        XCTAssertEqual(library.guides.count, 12)
        XCTAssertGreaterThan(library.contentVersion, 0)
    }

    func testSearchIgnoresAccentsAndFindsParagraphs() throws {
        let index = LibrarySearchIndex(guides: try BundleGuideRepository().loadGuides())
        let results = index.search("oracao")
        XCTAssertTrue(results.guideIDs.contains("escola-da-oracao"))
        XCTAssertFalse(results.hits.isEmpty)
        XCTAssertLessThanOrEqual(results.hits.count, LibrarySearchIndex.maxHits)
    }

    func testSearchJumpsToCatechismParagraphNumber() throws {
        let guides = try BundleGuideRepository().loadGuides()
        let index = LibrarySearchIndex(guides: guides)
        for query in ["§2217", "§ 2217", "2217"] {
            let hit = try XCTUnwrap(index.search(query).hits.first, query)
            let guide = try XCTUnwrap(guides.first { $0.id == hit.guideID })
            XCTAssertTrue(guide.chapters[hit.chapterIndex].paragraphs[hit.paragraphIndex].hasPrefix("2217."), query)
        }
        XCTAssertNil(LibrarySearchIndex.requestedParagraphNumber(in: "Parte III"))
    }

    func testSnippetIsCenteredOnMatch() {
        let text = String(repeating: "a ", count: 200) + "graça" + String(repeating: " b", count: 200)
        let snippet = LibrarySearchIndex.snippet(of: text, around: "graca", radius: 20)
        XCTAssertTrue(snippet.contains("graça"))
        XCTAssertTrue(snippet.hasPrefix("…") && snippet.hasSuffix("…"))
    }

    func testSpeechRatesStayWithinSynthesizerLimits() {
        for rate in SpeechRate.allCases {
            XCTAssertGreaterThanOrEqual(rate.utteranceRate, AVSpeechUtteranceMinimumSpeechRate)
            XCTAssertLessThanOrEqual(rate.utteranceRate, AVSpeechUtteranceMaximumSpeechRate)
        }
    }

    func testSpeechReaderUsesTextLanguageVoices() {
        let reader = SpeechReader(defaults: freshDefaults(#function))
        reader.setLanguage("en")
        XCTAssertEqual(reader.languageTag, "en")
        reader.setLanguage("pt-BR")
        XCTAssertEqual(reader.languageTag, "pt-BR")
        XCTAssertTrue(reader.voices.allSatisfy { $0.language.lowercased().hasPrefix("pt") })
    }

    private func freshDefaults(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func makeGuide(chapterCount: Int) -> Guide {
        Guide(
            id: "teste", title: "Guia", author: "Equipe", year: 2026,
            category: "Tema", description: "Resumo", context: "Contexto",
            chapters: (0..<chapterCount).map { Chapter(title: "Capítulo \($0 + 1)", paragraphs: ["Texto"]) },
            sourceURL: "https://example.invalid"
        )
    }
}
