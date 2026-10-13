import Foundation
import SwiftUI

@MainActor
final class RecentColorsStore: ObservableObject {
    @Published private(set) var recent: [ColorSwatch] = []

    private let defaultsKey = "atelier.recentColors"
    private let maxCount = 8
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func remember(_ color: Color) {
        let swatch = ColorSwatch(color: color)
        recent.removeAll {
            abs($0.red - swatch.red) < 0.01 &&
            abs($0.green - swatch.green) < 0.01 &&
            abs($0.blue - swatch.blue) < 0.01
        }
        recent.insert(swatch, at: 0)
        if recent.count > maxCount {
            recent = Array(recent.prefix(maxCount))
        }
        persist()
    }

    private func load() {
        guard let data = defaults.data(forKey: defaultsKey) else { return }
        if let decoded = try? JSONDecoder().decode([ColorSwatch].self, from: data) {
            recent = decoded
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(recent) {
            defaults.set(data, forKey: defaultsKey)
        }
    }
}
