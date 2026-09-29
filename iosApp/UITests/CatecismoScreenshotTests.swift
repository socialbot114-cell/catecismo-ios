import XCTest

final class CatecismoScreenshotTests: XCTestCase {
    func testReadingFlowScreenshots() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-AppleLanguages", "(pt-BR)", "-AppleLocale", "pt_BR"]
        app.launch()

        selectSection("section-saved", in: app)
        selectLanguage("Português (Brasil)", in: app)
        XCTAssertTrue(app.staticTexts["Minha biblioteca"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Seu caminho de leitura, salvo neste aparelho"].waitForExistence(timeout: 5))
        capture(named: "catecismo-library-pt")

        selectSection("section-home", in: app)
        XCTAssertTrue(app.staticTexts["Comece a ler"].waitForExistence(timeout: 10))
        capture(named: "catecismo-home-pt")

        selectSection("section-library", in: app)
        XCTAssertTrue(app.navigationBars["Biblioteca"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["library-search-field"].waitForExistence(timeout: 5))
        let portugueseGuide = app.staticTexts["O dom da fé"].firstMatch
        XCTAssertTrue(portugueseGuide.waitForExistence(timeout: 5))
        capture(named: "catecismo-guides-pt")

        selectSection("section-topics", in: app)
        XCTAssertTrue(app.staticTexts["Explore por tema"].waitForExistence(timeout: 5))
        capture(named: "catecismo-topics-pt")

        selectSection("section-pio-x", in: app)
        XCTAssertTrue(app.staticTexts["PORTUGUÊS (BRASIL)"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["ITALIANO"].exists)
        XCTAssertTrue(app.staticTexts["Catecismo de São Pio X"].exists)
        capture(named: "catecismo-pio-x-pt")

        selectSection("section-library", in: app)
        portugueseGuide.tap()
        XCTAssertTrue(app.staticTexts["Escutar e responder"].waitForExistence(timeout: 5))
        capture(named: "catecismo-reading-pt")

        app.navigationBars.buttons.firstMatch.tap()
        let search = app.textFields["library-search-field"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("Parte I\n")
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))
        let firstPart = app.staticTexts["Parte I — A Profissão da Fé"].firstMatch
        XCTAssertTrue(firstPart.waitForExistence(timeout: 5))
        capture(named: "catecismo-vatican-library-pt")
        firstPart.tap()
        XCTAssertTrue(app.staticTexts["Prólogo: a vida do homem é conhecer e amar a Deus"].waitForExistence(timeout: 5))
        capture(named: "catecismo-vatican-reading-pt")
        app.navigationBars.buttons.firstMatch.tap()
        if !search.exists { selectSection("section-library", in: app) }

        selectSection("section-saved", in: app)
        selectLanguage("English", in: app)
        XCTAssertTrue(app.staticTexts["My Library"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Your reading journey, saved on this device"].waitForExistence(timeout: 5))
        capture(named: "catecismo-library-en")

        selectSection("section-home", in: app)
        XCTAssertTrue(app.staticTexts["Start reading"].waitForExistence(timeout: 5))
        capture(named: "catecismo-home-en")

        selectSection("section-library", in: app)
        XCTAssertTrue(app.staticTexts["The Gift of Faith"].waitForExistence(timeout: 5))
        capture(named: "catecismo-guides-en")

        selectSection("section-pio-x", in: app)
        XCTAssertTrue(app.staticTexts["ENGLISH"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["The Catechism of Pope Saint Pius X · 1911"].exists)
        capture(named: "catecismo-pio-x-en")

        selectSection("section-saved", in: app)
        selectLanguage("Español", in: app)
        XCTAssertTrue(app.staticTexts["Mi biblioteca"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Tu recorrido de lectura, guardado en este dispositivo"].waitForExistence(timeout: 5))
        capture(named: "catecismo-library-es")

        selectSection("section-home", in: app)
        XCTAssertTrue(app.staticTexts["Empieza a leer"].waitForExistence(timeout: 5))
        capture(named: "catecismo-home-es")

        selectSection("section-library", in: app)
        XCTAssertTrue(app.staticTexts["El don de la fe"].waitForExistence(timeout: 5))
        capture(named: "catecismo-guides-es")

        selectSection("section-pio-x", in: app)
        XCTAssertTrue(app.staticTexts["ESPAÑOL"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Catecismo Mayor de San Pío X · 1906"].exists)
        capture(named: "catecismo-pio-x-es")

        selectSection("section-saved", in: app)
        selectLanguage("Français", in: app)
        XCTAssertTrue(app.staticTexts["Ma bibliothèque"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Votre parcours de lecture, enregistré sur cet appareil"].waitForExistence(timeout: 5))
        capture(named: "catecismo-library-fr")

        selectSection("section-home", in: app)
        XCTAssertTrue(app.staticTexts["Commencer la lecture"].waitForExistence(timeout: 5))
        capture(named: "catecismo-home-fr")

        selectSection("section-library", in: app)
        XCTAssertTrue(app.staticTexts["Le don de la foi"].waitForExistence(timeout: 5))
        capture(named: "catecismo-guides-fr")

        selectSection("section-pio-x", in: app)
        XCTAssertTrue(app.staticTexts["FRANÇAIS"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Catéchisme de Rome · édition complète de 1905"].exists)
        capture(named: "catecismo-pio-x-fr")

        selectSection("section-saved", in: app)
        selectLanguage("Português (Brasil)", in: app)
        XCTAssertTrue(app.staticTexts["Minha biblioteca"].waitForExistence(timeout: 10))
    }

    private func selectLanguage(_ name: String, in app: XCUIApplication) {
        let picker = app.buttons.matching(identifier: "app-language-picker").firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 10))
        picker.tap()
        let option = app.buttons.matching(NSPredicate(format: "label == %@", name)).firstMatch
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        option.tap()
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
