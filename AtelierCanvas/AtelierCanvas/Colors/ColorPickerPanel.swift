import SwiftUI

struct ColorPickerPanel: View {
    @Binding var selectedColor: Color
    @ObservedObject var recentColors: RecentColorsStore
    var onColorCommitted: ((Color) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Colour")
                .font(AtelierTypography.headline)
                .foregroundStyle(AtelierTheme.textPrimary)

            ColorPicker("Colour wheel", selection: $selectedColor, supportsOpacity: false)
                .labelsHidden()
                .frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityLabel("Colour wheel")
                .onChange(of: selectedColor) { _, newValue in
                    onColorCommitted?(newValue)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text("Presets")
                    .font(AtelierTypography.caption)
                    .foregroundStyle(AtelierTheme.textSecondary)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                    ForEach(Array(ColorSystem.presets.enumerated()), id: \.offset) { index, color in
                        colorButton(color, label: "Preset colour \(index + 1)")
                    }
                }
            }

            if !recentColors.recent.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent")
                        .font(AtelierTypography.caption)
                        .foregroundStyle(AtelierTheme.textSecondary)
                    HStack(spacing: 8) {
                        ForEach(recentColors.recent) { swatch in
                            colorButton(swatch.color, label: "Recent colour")
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 28, height: 28)
                    .overlay(Circle().stroke(AtelierTheme.border, lineWidth: 1))
                    .accessibilityHidden(true)
                Text("Selected")
                    .font(AtelierTypography.caption)
                    .foregroundStyle(AtelierTheme.textSecondary)
            }
        }
        .padding(16)
        .atelierPanel()
    }

    private func colorButton(_ color: Color, label: String) -> some View {
        Button {
            selectedColor = color
            recentColors.remember(color)
            onColorCommitted?(color)
        } label: {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color)
                .frame(height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(colorsMatch(color, selectedColor) ? AtelierTheme.accent : AtelierTheme.border, lineWidth: colorsMatch(color, selectedColor) ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func colorsMatch(_ lhs: Color, _ rhs: Color) -> Bool {
        let a = ColorSwatch(color: lhs)
        let b = ColorSwatch(color: rhs)
        return abs(a.red - b.red) < 0.02 && abs(a.green - b.green) < 0.02 && abs(a.blue - b.blue) < 0.02
    }
}
