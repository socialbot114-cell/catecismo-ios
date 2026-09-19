import XCTest

final class CatecismoScreenshotTests: XCTestCase {
    func testHomeScreenshot() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-AppleLanguages", "(pt-BR)", "-AppleLocale", "pt_BR"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Comece a ler"].waitForExistence(timeout: 10))
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "catecismo-home"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
