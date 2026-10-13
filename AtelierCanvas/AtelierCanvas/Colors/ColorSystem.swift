import SwiftUI
import UIKit

enum ColorSystem {
    static let presets: [Color] = [
        Color(red: 0.05, green: 0.05, blue: 0.06),
        Color(red: 0.96, green: 0.96, blue: 0.97),
        Color(red: 0.78, green: 0.18, blue: 0.18),
        Color(red: 0.90, green: 0.45, blue: 0.16),
        Color(red: 0.93, green: 0.76, blue: 0.20),
        Color(red: 0.25, green: 0.62, blue: 0.34),
        Color(red: 0.18, green: 0.48, blue: 0.82),
        Color(red: 0.42, green: 0.30, blue: 0.78),
        Color(red: 0.78, green: 0.58, blue: 0.38),
        Color(red: 0.55, green: 0.38, blue: 0.28),
        Color(red: 0.45, green: 0.48, blue: 0.52),
        Color(red: 0.18, green: 0.72, blue: 0.68)
    ]

    static func uiColor(from color: Color) -> UIColor {
        UIColor(color)
    }
}

struct ColorSwatch: Identifiable, Equatable, Codable {
    let id: UUID
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double

    init(id: UUID = UUID(), color: Color) {
        let ui = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 1
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.id = id
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }

    init(id: UUID = UUID(), red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.id = id
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: opacity)
    }
}
