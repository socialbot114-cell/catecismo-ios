import XCTest

final class CatecismoScreenshotTests: XCTestCase {
    private struct LocaleCase {
        let slug: String
        let languagePreference: String
        let appleLanguage: String
        let appleLocale: String
        let homeTitle: String
        let guideTitle: String
        let myLibraryTitle: String
        let quotesTitle: String
    }

    private let locales = [
        LocaleCase(slug: "pt", languagePreference: "pt-BR", appleLanguage: "pt-BR", appleLocale: "pt_BR", homeTitle: "Comece a ler", guideTitle: "O dom da fé", myLibraryTitle: "Minha biblioteca", quotesTitle: "Citações"),
        LocaleCase(slug: "en", languagePreference: "en", appleLanguage: "en", appleLocale: "en_US", homeTitle: "Start reading", guideTitle: "The Gift of Faith", myLibraryTitle: "My Library", quotesTitle: "Quotes"),
        LocaleCase(slug: "es", languagePreference: "es", appleLanguage: "es", appleLocale: "es_ES", homeTitle: "Empieza a leer", guideTitle: "El don de la fe", myLibraryTitle: "Mi biblioteca", quotesTitle: "Citas"),
        LocaleCase(slug: "fr", languagePreference: "fr", appleLanguage: "fr", appleLocale: "fr_FR", homeTitle: "Commencer la lecture", guideTitle: "Le don de la foi", myLibraryTitle: "Ma bibliothèque", quotesTitle: "Citations"),
    ]

    func testAllScreenshotsInAllLanguages() {
        let app = XCUIApplication()
        for locale in locales {
            app.launchArguments = [
                "-ui-testing",
                "-catecismo.language", locale.languagePreference,
                "-AppleLanguages", "(\(locale.appleLanguage))",
                "-AppleLocale", locale.appleLocale,
            ]
            app.launch()
            if locale.slug == "pt" { seedSavedContent(in: app) }
            audit(locale, in: app)
            app.terminate()
        }
    }

    private func audit(_ locale: LocaleCase, in app: XCUIApplication) {
        selectSection("section-saved", in: app)
        waitForScreen("screen-saved", in: app)
        XCTAssertTrue(app.staticTexts[locale.myLibraryTitle].firstMatch.waitForExistence(timeout: 10))
        capture(named: "\(locale.slug)-my-library")

        let quoteHeading = app.staticTexts[locale.quotesTitle].firstMatch
        scrollDownUntilHittable(quoteHeading, in: app)
        capture(named: "\(locale.slug)-my-library-quotes")

        selectSection("section-home", in: app)
        waitForScreen("screen-home", in: app)
        XCTAssertTrue(app.staticTexts[locale.homeTitle].waitForExistence(timeout: 10))
        capture(named: "\(locale.slug)-home")
        let offlineText = app.descendants(matching: .any).matching(identifier: "home-catechism-section").firstMatch
        scrollDownUntilHittable(offlineText, in: app)
        capture(named: "\(locale.slug)-home-offline-catechism")

        selectSection("section-library", in: app)
        waitForScreen("screen-library", in: app)
        let clearSearch = app.buttons["library-clear-search"]
        if clearSearch.exists { clearSearch.tap() }
        let search = app.textFields["library-search-field"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[locale.guideTitle].firstMatch.waitForExistence(timeout: 5))
        capture(named: "\(locale.slug)-library")

        selectSection("section-topics", in: app)
        waitForScreen("screen-topics", in: app)
        capture(named: "\(locale.slug)-topics")
        let topicCards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "topic-category-"))
        let topic = topicCards.allElementsBoundByIndex.first { $0.identifier != "topic-category-Catecismo" }
        XCTAssertNotNil(topic, "Expected an authorial topic card for \(locale.slug)")
        topic?.tap()
        waitForScreen("screen-topic-detail", in: app)
        capture(named: "\(locale.slug)-topic-detail")

        selectSection("section-library", in: app)
        waitForScreen("screen-library", in: app)
        if clearSearch.exists { clearSearch.tap() }
        let guide = app.staticTexts[locale.guideTitle].firstMatch
        XCTAssertTrue(guide.waitForExistence(timeout: 5))
        guide.tap()
        waitForScreen("screen-reader", in: app)
        capture(named: "\(locale.slug)-guide-reader")

        selectSection("section-home", in: app)
        selectSection("section-library", in: app)
        waitForScreen("screen-library", in: app)
        let catechismSearch = app.textFields["library-search-field"]
        XCTAssertTrue(catechismSearch.waitForExistence(timeout: 5))
        catechismSearch.tap()
        catechismSearch.typeText("Parte III\n")
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))
        let thirdPart = app.staticTexts["Parte III — A Vida em Cristo"].firstMatch
        XCTAssertTrue(thirdPart.waitForExistence(timeout: 5))
        capture(named: "\(locale.slug)-catechism-search")
        thirdPart.tap()
        waitForScreen("screen-reader", in: app)
        capture(named: "\(locale.slug)-catechism-reader")

        let chapterPicker = app.buttons["chapter-picker-button"].firstMatch
        scrollUpUntilHittable(chapterPicker, in: app)
        chapterPicker.tap()
        capture(named: "\(locale.slug)-chapter-picker")
        selectChapter("O quarto mandamento", in: app)
        captureParagraph(2217, named: "\(locale.slug)-paragraph-2217", in: app)

        scrollUpUntilHittable(chapterPicker, in: app)
        chapterPicker.tap()
        selectChapter("O sétimo mandamento", in: app)
        let chapterTitle = app.descendants(matching: .any).matching(identifier: "selected-chapter-title").firstMatch
        XCTAssertTrue(chapterTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(chapterTitle.label, "O sétimo mandamento")
        scrollUpUntilHittable(chapterPicker, in: app)
        capture(named: "\(locale.slug)-reader-seventh-commandment")
        captureParagraph(2439, named: "\(locale.slug)-paragraph-2439", in: app)
    }

    private func seedSavedContent(in app: XCUIApplication) {
        selectSection("section-library", in: app)
        waitForScreen("screen-library", in: app)
        let guide = app.staticTexts[locales[0].guideTitle].firstMatch
        XCTAssertTrue(guide.waitForExistence(timeout: 10))
        guide.tap()
        waitForScreen("screen-reader", in: app)
        let favorite = app.buttons["guide-favorite-button"]
        XCTAssertTrue(favorite.waitForExistence(timeout: 5))
        favorite.tap()
        let quote = app.buttons.matching(identifier: "save-quote-button").firstMatch
        scrollDownUntilHittable(quote, in: app)
        quote.tap()
        let complete = app.buttons["complete-chapter-button"]
        scrollDownUntilHittable(complete, in: app)
        complete.tap()
        selectSection("section-saved", in: app)
        waitForScreen("screen-saved", in: app)
    }

    private func waitForScreen(_ identifier: String, in app: XCUIApplication) {
        let screen = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(screen.waitForExistence(timeout: 10), "Missing screen: \(identifier)")
    }

    private func captureParagraph(_ number: Int, named name: String, in app: XCUIApplication) {
        let paragraph = app.descendants(matching: .any)
            .matching(identifier: "catechism-paragraph-\(number)")
            .firstMatch
        scrollDownUntilHittable(paragraph, in: app)
        capture(named: name)
    }

    private func selectChapter(_ title: String, in app: XCUIApplication) {
        let chapter = app.buttons.matching(NSPredicate(format: "label == %@", title)).firstMatch
        let visibleChapterOptions = app.buttons.matching(NSPredicate(format: "label CONTAINS[cd] %@", "mandamento"))
        XCTAssertTrue(visibleChapterOptions.firstMatch.waitForExistence(timeout: 5), "Chapter menu did not open")
        for _ in 0..<20 {
            if chapter.isHittable {
                chapter.tap()
                return
            }
            let visibleOptions = visibleChapterOptions.allElementsBoundByIndex
            if let lastVisibleOption = visibleOptions.last, lastVisibleOption.isHittable {
                lastVisibleOption.swipeUp()
            } else {
                app.swipeUp()
            }
        }
        XCTAssertTrue(chapter.waitForExistence(timeout: 5), "Missing chapter option: \(title)")
        chapter.tap()
    }

    private func scrollDownUntilHittable(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<48 {
            if element.isHittable { return }
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.55, dy: 0.8))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.55, dy: 0.48))
            start.press(forDuration: 0.05, thenDragTo: end)
        }
        XCTAssertTrue(element.isHittable, "Could not scroll to \(element.identifier)")
    }

    private func scrollUpUntilHittable(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<24 {
            if element.isHittable { return }
            app.swipeDown()
        }
        XCTAssertTrue(element.isHittable, "Could not scroll back to \(element.identifier)")
    }

    private func capture(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func selectSection(_ identifier: String, in app: XCUIApplication) {
        let button = app.buttons.matching(identifier: identifier).firstMatch
        if button.waitForExistence(timeout: 2) {
            button.tap()
            return
        }

        let cell = app.cells.matching(identifier: identifier).firstMatch
        if cell.waitForExistence(timeout: 2) {
            cell.tap()
            return
        }

        let section = app.descendants(matching: .any)
            .matching(identifier: identifier)
            .matching(NSPredicate(format: "isHittable == true"))
            .firstMatch
        XCTAssertTrue(section.waitForExistence(timeout: 10), "Missing section: \(identifier)")
        section.tap()
    }
}
