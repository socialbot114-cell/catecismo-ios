import SwiftUI

enum CatecismoTheme {
    static let navy = Color(red: 0.047, green: 0.118, blue: 0.227)
    static let navyDeep = Color(red: 0.024, green: 0.055, blue: 0.118)
    static let gold = Color(red: 0.784, green: 0.608, blue: 0.290)
    static let canvas = Color(red: 0.961, green: 0.945, blue: 0.902)
    static let paper = Color(red: 1.000, green: 0.992, blue: 0.973)
    static let ink = Color(red: 0.094, green: 0.133, blue: 0.208)
    static let muted = Color(red: 0.392, green: 0.435, blue: 0.510)
    static let accent = navy

    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}
