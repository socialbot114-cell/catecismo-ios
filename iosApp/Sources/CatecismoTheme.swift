import SwiftUI

enum CatecismoTheme {
    static let navy = Color(red: 0.047, green: 0.118, blue: 0.227)
    static let navyDeep = Color(red: 0.024, green: 0.055, blue: 0.118)
    static let gold = Color(red: 0.784, green: 0.608, blue: 0.290)
    static let canvas = Color(red: 0.961, green: 0.945, blue: 0.902)
    static let paper = Color(red: 1.000, green: 0.992, blue: 0.973)
    static let ink = Color(red: 0.094, green: 0.133, blue: 0.208)
    static let muted = Color(red: 0.392, green: 0.435, blue: 0.510)
    static let highlight = Color(red: 0.784, green: 0.608, blue: 0.290).opacity(0.16)
    static let accent = navy

    /// Serif display font that follows Dynamic Type; `size` picks the closest text style.
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        let style: Font.TextStyle
        switch size {
        case 32...: style = .largeTitle
        case 27..<32: style = .title
        case 22..<27: style = .title2
        default: style = .title3
        }
        return .system(style, design: .serif).weight(weight)
    }
}

/// Text size used by the reader, on top of the system Dynamic Type setting.
enum ReaderTextSize: String, CaseIterable, Identifiable {
    case small, standard, large, extraLarge

    static let preferenceKey = "catecismo.reader.textSize"
    var id: String { rawValue }

    var font: Font {
        switch self {
        case .small: return .system(.callout, design: .serif)
        case .standard: return .system(.body, design: .serif)
        case .large: return .system(.title3, design: .serif)
        case .extraLarge: return .system(.title2, design: .serif)
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .small: return "Pequeno"
        case .standard: return "Padrão"
        case .large: return "Grande"
        case .extraLarge: return "Muito grande"
        }
    }
}
