import SwiftUI

enum CatecismoTheme {
    static let wine = Color(red: 0.45, green: 0.11, blue: 0.18)
    static let wineDeep = Color(red: 0.30, green: 0.07, blue: 0.12)
    static let gold = Color(red: 0.76, green: 0.60, blue: 0.22)
    static let accent = wine

    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}
