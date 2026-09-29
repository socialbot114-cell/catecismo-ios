import XCTest

final class CatecismoScreenshotTests: XCTestCase {
    private struct LocaleCase {
        let slug: String
        let pickerOption: String
        let homeTitle: String
        let guideTitle: String
        let libraryBackLabel: String
        let myLibraryTitle: String
        let quotesTitle: String
        let topicsBackLabel: String
    }

    private let locales = [
        LocaleCase(slug: "pt", pickerOption: "Português (Brasil)", homeTitle: "Comece a ler", guideTitle: "O dom da fé", libraryBackLabel: "Biblioteca", myLibraryTitle: "Minha biblioteca", quotesTitle: "Citações", topicsBackLabel: "Temas"),
        LocaleCase(slug: "en", pickerOption: "English", homeTitle: "Start reading", guideTitle: "The Gift of Faith", libraryBackLabel: "Library", myLibraryTitle: "My Library", quotesTitle: "Quotes", topicsBackLabel: "Topics"),
        LocaleCase(slug: "es", pickerOption: "Español", homeTitle: "Empieza a leer", guideTitle: "El don de la fe", libraryBackLabel: "Biblioteca", myLibraryTitle: "Mi biblioteca", quotesTitle: "Citas", topicsBackLabel: "Temas"),
        LocaleCase(slug: "fr", pickerOption: "Français", homeTitle: "Commencer la lecture", guideTitle: "Le don de la foi", libraryBackLabel: "Bibliothèque", myLibraryTitle: "Ma bibliothèque", quotesTitle: "Citations", topicsBackLabel: "Thèmes"),
    ]

    func testAllScreenshotsInAllLanguages() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-AppleLanguages", "(pt-BR)", "-AppleLocale", "pt_BR"]
        app.launch()

        selectSection("section-saved", in: app)
        selectLanguage(locales[0].pickerOption, in: app)
        seedSavedContent(in: app)

        for locale in locales {
            audit(locale, in: app)
        }
    }

    private func audit(_ locale: LocaleCase, in app: XCUIApplication) {
        selectSection("section-saved", in: app)
        selectLanguage(locale.pickerOption, in: app)
        waitForScreen("screen-saved", in: app)
        XCTAssertTrue(app.staticTexts[locale.myLibraryTitle].firstMatch.waitForExistence(timeout: 10))
        capture(named: "\(locale.slug)-my-library")

        let quoteHeading = app.staticTexts[locale.quotesTitle].firstMatch
        scrollDownUntilHittable(quoteHeading, in: app)
        capture(named: "\(locale.slug)-my-library-quotes")
        scrollUpUntilHittable(app.descendants(matching: .any).matching(identifier: "my-library-heading").firstMatch, in: app)

        let picker = app.descendants(matching: .any).matching(identifier: "app-language-picker").firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 10))
        picker.tap()
        let option = app.buttons.matching(NSPredicate(format: "label == %@", locale.pickerOption)).firstMatch
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        capture(named: "\(locale.slug)-language-picker")
        option.tap()

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
        returnToPreviousScreen(locale.topicsBackLabel, in: app)

        selectSection("section-library", in: app)
        waitForScreen("screen-library", in: app)
        if clearSearch.exists { clearSearch.tap() }
        let guide = app.staticTexts[locale.guideTitle].firstMatch
        XCTAssertTrue(guide.waitForExistence(timeout: 5))
        guide.tap()
        waitForScreen("screen-reader", in: app)
        capture(named: "\(locale.slug)-guide-reader")
        returnToPreviousScreen(locale.libraryBackLabel, in: app)

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
        captureParagraph("2217.", named: "\(locale.slug)-paragraph-2217", in: app)

        scrollUpUntilHittable(chapterPicker, in: app)
        chapterPicker.tap()
        selectChapter("O sétimo mandamento", in: app)
        captureParagraph("2439.", named: "\(locale.slug)-paragraph-2439", in: app)
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

    private func selectLanguage(_ name: String, in app: XCUIApplication) {
        let picker = app.descendants(matching: .any).matching(identifier: "app-language-picker").firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 10))
        picker.tap()
        let option = app.buttons.matching(NSPredicate(format: "label == %@", name)).firstMatch
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        option.tap()
    }

    private func returnToPreviousScreen(_ label: String, in app: XCUIApplication) {
        let back = app.navigationBars.buttons[label].firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 5), "Expected the navigation back button")
        back.tap()
    }

    private func waitForScreen(_ identifier: String, in app: XCUIApplication) {
        let screen = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(screen.waitForExistence(timeout: 10), "Missing screen: \(identifier)")
    }

    private func captureParagraph(_ marker: String, named name: String, in app: XCUIApplication) {
        let paragraph = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", marker)).firstMatch
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
        for _ in 0..<24 {
            if element.isHittable { return }
            app.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(element.isHittable, "Could not scroll to \(element.identifier)")
    }

    private func scrollUpUntilHittable(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<24 {
            if element.isHittable { return }
            app.scrollViews.firstMatch.swipeDown()
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
