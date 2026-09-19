import XCTest

final class CatecismoScreenshotTests: XCTestCase {
    func testReadingFlowScreenshots() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-AppleLanguages", "(pt-BR)", "-AppleLocale", "pt_BR"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Comece a ler"].waitForExistence(timeout: 10))
        capture(named: "catecismo-home")

        let libraryTab = app.tabBars.buttons["Biblioteca"]
        XCTAssertTrue(libraryTab.waitForExistence(timeout: 5))
        libraryTab.tap()
        XCTAssertTrue(app.navigationBars["Biblioteca"].waitForExistence(timeout: 5))

        let guide = app.staticTexts["O dom da fé"].firstMatch
        XCTAssertTrue(guide.waitForExistence(timeout: 5))
        guide.tap()
        XCTAssertTrue(app.staticTexts["Escutar e responder"].waitForExistence(timeout: 5))
        capture(named: "catecismo-reading")

        let paragraph = app.staticTexts["A fé começa quando a pessoa se abre para uma presença maior que si mesma e acolhe uma palavra de amor."]
        if paragraph.waitForExistence(timeout: 3) {
            app.scrollViews.firstMatch.swipeUp()
        }
        capture(named: "catecismo-reading-scrolled")
    }

    private func capture(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
