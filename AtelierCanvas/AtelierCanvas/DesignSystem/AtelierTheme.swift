import SwiftUI

enum AtelierTheme {
    static let background = Color(red: 0.07, green: 0.07, blue: 0.08)
    static let surface = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let surfaceElevated = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let border = Color.white.opacity(0.08)
    static let textPrimary = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let textSecondary = Color(red: 0.62, green: 0.63, blue: 0.66)
    static let accent = Color(red: 0.78, green: 0.58, blue: 0.38)
    static let accentSoft = Color(red: 0.78, green: 0.58, blue: 0.38).opacity(0.18)
    static let danger = Color(red: 0.92, green: 0.35, blue: 0.32)
    static let canvasPaper = Color(red: 0.98, green: 0.98, blue: 0.97)
    static let toolSelected = Color.white.opacity(0.14)
    static let toolIdle = Color.clear

    static let cornerRadius: CGFloat = 14
    static let compactCorner: CGFloat = 10
    static let toolbarHeight: CGFloat = 52
}

enum AtelierTypography {
    static let brand = Font.system(size: 34, weight: .semibold, design: .serif)
    static let title = Font.system(size: 22, weight: .semibold, design: .default)
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    static let micro = Font.system(size: 11, weight: .medium, design: .default)
}
