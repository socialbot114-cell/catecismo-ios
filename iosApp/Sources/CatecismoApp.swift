import SwiftUI

@main
struct CatecismoApp: App {
    @StateObject private var library = LibraryViewModel()
    @AppStorage(AppLanguage.preferenceKey) private var language = AppLanguageChoice.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(library)
                .environment(\.locale, AppLanguage.locale(for: language))
        }
    }
}
