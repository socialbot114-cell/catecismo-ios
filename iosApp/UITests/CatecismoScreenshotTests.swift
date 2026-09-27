import XCTest

final class CatecismoScreenshotTests: XCTestCase {
    func testReadingFlowScreenshots() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-AppleLanguages", "(pt-BR)", "-AppleLocale", "pt_BR"]
        app.launch()

        selectSection("section-saved", in: app)
        let languagePicker = app.descendants(matching: .any).matching(identifier: "app-language-picker").firstMatch
        XCTAssertTrue(languagePicker.waitForExistence(timeout: 10))
        languagePicker.tap()
        let portugueseOption = app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", "Português (Brasil)")).firstMatch
        XCTAssertTrue(portugueseOption.waitForExistence(timeout: 5))
        portugueseOption.tap()
        XCTAssertTrue(app.navigationBars["Minha biblioteca"].waitForExistence(timeout: 5))

        selectSection("section-home", in: app)
        XCTAssertTrue(app.staticTexts["Comece a ler"].waitForExistence(timeout: 10))
        capture(named: "catecismo-home")

        selectSection("section-library", in: app)
        XCTAssertTrue(app.navigationBars["Biblioteca"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["Buscar guia ou tema"].waitForExistence(timeout: 5))
        capture(named: "catecismo-library")

        selectSection("section-topics", in: app)
        XCTAssertTrue(app.staticTexts["Explore por tema"].waitForExistence(timeout: 5))
        capture(named: "catecismo-topics")

        selectSection("section-saved", in: app)
        XCTAssertTrue(app.navigationBars["Minha biblioteca"].waitForExistence(timeout: 5))
        capture(named: "catecismo-saved")

        selectSection("section-pio-x", in: app)
        XCTAssertTrue(app.staticTexts["PORTUGUÊS (BRASIL)"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["ITALIANO"].exists)
        XCTAssertTrue(app.staticTexts["Catecismo de São Pio X"].exists)
        capture(named: "catecismo-pio-x")

        selectSection("section-library", in: app)

        let guide = app.staticTexts["O dom da fé"].firstMatch
        XCTAssertTrue(guide.waitForExistence(timeout: 5))
        guide.tap()
        XCTAssertTrue(app.staticTexts["Escutar e responder"].waitForExistence(timeout: 5))
        capture(named: "catecismo-reading")

        selectSection("section-saved", in: app)
        XCTAssertTrue(languagePicker.waitForExistence(timeout: 5))
        languagePicker.tap()
        let englishOption = app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", "English")).firstMatch
        XCTAssertTrue(englishOption.waitForExistence(timeout: 5))
        englishOption.tap()
        XCTAssertTrue(app.navigationBars["My Library"].waitForExistence(timeout: 5))
        selectSection("section-library", in: app)
        XCTAssertTrue(app.staticTexts["The Gift of Faith"].waitForExistence(timeout: 5))
        capture(named: "catecismo-library-en")

        selectSection("section-saved", in: app)
        languagePicker.tap()
        portugueseOption.tap()
        XCTAssertTrue(app.navigationBars["Minha biblioteca"].waitForExistence(timeout: 5))
    }

    private func capture(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func selectSection(_ identifier: String, in app: XCUIApplication) {
        let section = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(section.waitForExistence(timeout: 10), "Missing section: \(identifier)")
        section.tap()
    }
}
