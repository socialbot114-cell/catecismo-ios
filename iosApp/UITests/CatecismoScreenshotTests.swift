import XCTest

final class CatecismoScreenshotTests: XCTestCase {
    func testReadingFlowScreenshots() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-AppleLanguages", "(pt-BR)", "-AppleLocale", "pt_BR"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Catecismo completo"].waitForExistence(timeout: 10))
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
        capture(named: "catecismo-library")

        let partTitle = app.staticTexts["Catecismo – Parte I: A Profissão da Fé"].firstMatch
        if partTitle.waitForExistence(timeout: 5) {
            partTitle.tap()
            let firstSection = app.staticTexts["Prólogo: a vida do homem é conhecer e amar a Deus"].firstMatch
            if firstSection.waitForExistence(timeout: 5) {
                firstSection.tap()
                capture(named: "catecismo-reading-integral")
                app.navigationBars.buttons.firstMatch.tap()
                app.navigationBars.buttons.firstMatch.tap()
            } else {
                capture(named: "catecismo-reading-integral")
                app.navigationBars.buttons.firstMatch.tap()
            }
        }

        let guide = app.staticTexts["O dom da fé"].firstMatch
        if guide.waitForExistence(timeout: 5) {
            guide.tap()
            XCTAssertTrue(app.staticTexts["Escutar e responder"].waitForExistence(timeout: 5))
            capture(named: "catecismo-reading")
        }
    }

    private func capture(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
