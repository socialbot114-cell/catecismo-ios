import Foundation
import SwiftUI

enum AppLanguageChoice: String, CaseIterable, Identifiable {
    case system = "system"
    case portuguese = "pt-BR"
    case english = "en"
    case spanish = "es"
    case french = "fr"

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .system: return "Idioma do dispositivo"
        case .portuguese: return "Português (Brasil)"
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        }
    }
}

enum AppLanguage {
    static let preferenceKey = "catecismo.language"

    static func locale(for selection: String) -> Locale {
        if selection == AppLanguageChoice.system.rawValue {
            return Locale(identifier: contentTag(for: .autoupdatingCurrent))
        }
        return Locale(identifier: selection)
    }

    static func contentTag(for locale: Locale) -> String {
        let identifier = locale.identifier.replacingOccurrences(of: "_", with: "-")
        let language = identifier.split(separator: "-").first?.lowercased() ?? "pt"
        switch language {
        case "en": return "en"
        case "es": return "es"
        case "fr": return "fr"
        case "pt": return "pt-BR"
        default: return "pt-BR"
        }
    }
}
