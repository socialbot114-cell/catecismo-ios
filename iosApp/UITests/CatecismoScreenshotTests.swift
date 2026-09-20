import XCTest

final class CatecismoScreenshotTests: XCTestCase {
    func testReadingFlowScreenshots() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-AppleLanguages", "(pt-BR)", "-AppleLocale", "pt_BR"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Comece a ler"].waitForExistence(timeout: 10))
        capture(named: "catecismo-home")

        let libraryTab = app.tabBars.buttons["Biblioteca"]
        if libraryTab.waitForExistence(timeout: 2) {
            libraryTab.tap()
        } else {
            let sidebarItem = app.staticTexts["Biblioteca"].firstMatch
            XCTAssertTrue(sidebarItem.waitForExistence(timeout: 5))
            sidebarItem.tap()
        }
        XCTAssertTrue(app.navigationBars["Biblioteca"].waitForExistence(timeout: 5))

        let guide = app.staticTexts["O dom da fé"].firstMatch
        XCTAssertTrue(guide.waitForExistence(timeout: 5))
        guide.tap()
        XCTAssertTrue(app.staticTexts["Escutar e responder"].waitForExistence(timeout: 5))
        capture(named: "catecismo-reading")

        app.scrollViews.firstMatch.swipeUp()
        capture(named: "catecismo-reading-scrolled")
    }

    private func capture(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
