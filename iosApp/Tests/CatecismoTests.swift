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
        XCTAssertEqual(guides.count, 8)
        XCTAssertTrue(guides.allSatisfy { !$0.id.isEmpty && !$0.chapters.isEmpty })
    }

    func testAppLanguageMapsDeviceRegionToSupportedContentBundle() {
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "en-GB")), "en")
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "es-MX")), "es")
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "fr-CA")), "fr")
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "pt-PT")), "pt-BR")
        XCTAssertEqual(AppLanguage.contentTag(for: Locale(identifier: "de-DE")), "pt-BR")
    }

    func testLocalizedGuideBundlesKeepStableIDsAndChapterStructure() throws {
        let repository = BundleGuideRepository()
        let baseGuides = try repository.loadGuides(languageCode: "pt-BR")
        let baseByID = Dictionary(uniqueKeysWithValues: baseGuides.map { ($0.id, $0) })

        for language in ["en", "es", "fr"] {
            let translated = try repository.loadGuides(languageCode: language)
            XCTAssertEqual(Set(translated.map(\.id)), Set(baseByID.keys), "Missing guide IDs for \(language)")
            for guide in translated {
                let base = try XCTUnwrap(baseByID[guide.id])
                XCTAssertEqual(guide.chapterCount, base.chapterCount, "Chapter count differs for \(language)/\(guide.id)")
                for index in guide.chapters.indices {
                    XCTAssertEqual(guide.chapters[index].paragraphs.count, base.chapters[index].paragraphs.count, "Paragraph count differs for \(language)/\(guide.id)")
                }
            }
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

    private func makeGuide(chapterCount: Int) -> Guide {
        Guide(
            id: "teste", title: "Guia", author: "Equipe", year: 2026,
            category: "Tema", description: "Resumo", context: "Contexto",
            chapters: (0..<chapterCount).map { Chapter(title: "Capítulo \($0 + 1)", paragraphs: ["Texto"]) },
            sourceURL: "https://example.invalid"
        )
    }
}
