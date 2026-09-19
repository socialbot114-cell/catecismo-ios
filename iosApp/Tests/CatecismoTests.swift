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
}
