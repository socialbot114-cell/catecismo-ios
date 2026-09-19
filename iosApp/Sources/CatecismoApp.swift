import SwiftUI

@main
struct CatecismoApp: App {
    @StateObject private var library = LibraryViewModel()
    var body: some Scene { WindowGroup { ContentView().environmentObject(library) } }
}
