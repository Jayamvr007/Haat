import SwiftUI

extension Color {
    // Exact Figma Colors from Node 1-2616
    static let haatRed = Color(hex: "BD0233")        // Primary action, prices, View all
    static let haatGreen = Color(hex: "00A36C")       // Deal badges, Open status
    static let haatBackground = Color(hex: "F2F4F7")  // Screen background
    static let haatTextDark = Color(hex: "1B1721")    // Titles, bold text
    static let haatTextLight = Color(hex: "54536A")   // Subtitles, descriptions
    static let haatSearchBg = Color(hex: "F2F4F7")    // Search bar background
    static let haatYellow = Color(hex: "FFC800")      // Free badge
    static let haatBorder = Color(hex: "EAEAEA")      // Card borders
    static let haatLightBlue = Color(hex: "F4F6FB")   // Promo banner bg
    static let haatPlaceholder = Color(hex: "72708F")  // Search placeholder
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
