import XCTest

final class CatecismoScreenshotTests: XCTestCase {
    func testReadingFlowScreenshots() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-AppleLanguages", "(pt-BR)", "-AppleLocale", "pt_BR"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Comece a ler"].waitForExistence(timeout: 10))
        capture(named: "catecismo-home")

        selectSection("Biblioteca", in: app)
        XCTAssertTrue(app.navigationBars["Biblioteca"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["Buscar guia ou tema"].waitForExistence(timeout: 5))
        capture(named: "catecismo-library")

        selectSection("Temas", in: app)
        XCTAssertTrue(app.staticTexts["Explore por tema"].waitForExistence(timeout: 5))
        capture(named: "catecismo-topics")

        selectSection("Minha biblioteca", in: app)
        XCTAssertTrue(app.navigationBars["Minha biblioteca"].waitForExistence(timeout: 5))
        capture(named: "catecismo-saved")

        selectSection("Biblioteca", in: app)

        let guide = app.staticTexts["O dom da fé"].firstMatch
        XCTAssertTrue(guide.waitForExistence(timeout: 5))
        guide.tap()
        XCTAssertTrue(app.staticTexts["Escutar e responder"].waitForExistence(timeout: 5))
        capture(named: "catecismo-reading")
    }

    private func capture(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func selectSection(_ name: String, in app: XCUIApplication) {
        let tab = app.tabBars.buttons[name]
        if tab.waitForExistence(timeout: 2) {
            tab.tap()
        } else if app.buttons[name].waitForExistence(timeout: 2) {
            app.buttons[name].tap()
        } else {
            let sidebarItem = app.staticTexts[name].firstMatch
            XCTAssertTrue(sidebarItem.waitForExistence(timeout: 5), "Missing sidebar item: \(name)")
            sidebarItem.tap()
        }
    }
}
