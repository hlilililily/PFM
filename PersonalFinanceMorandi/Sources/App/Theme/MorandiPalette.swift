import SwiftUI

enum MorandiPalette {
    static let background = Color(red: 245 / 255, green: 242 / 255, blue: 237 / 255)
    static let card = Color(red: 232 / 255, green: 228 / 255, blue: 221 / 255)
    static let accent = Color(red: 178 / 255, green: 164 / 255, blue: 155 / 255)
    static let accentSoft = Color(red: 206 / 255, green: 196 / 255, blue: 188 / 255)
    static let textPrimary = Color(red: 76 / 255, green: 73 / 255, blue: 69 / 255)
    static let textSecondary = Color(red: 120 / 255, green: 115 / 255, blue: 110 / 255)
    static let positive = Color(red: 177 / 255, green: 191 / 255, blue: 168 / 255)
    static let negative = Color(red: 209 / 255, green: 166 / 255, blue: 156 / 255)
}

extension LinearGradient {
    static var morandiCard: LinearGradient {
        LinearGradient(
            colors: [MorandiPalette.card, MorandiPalette.accentSoft],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
