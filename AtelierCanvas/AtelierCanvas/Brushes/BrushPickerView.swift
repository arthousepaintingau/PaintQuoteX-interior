import SwiftUI

struct BrushPickerView: View {
    @Binding var selectedBrush: BrushKind
    var onSelect: ((BrushKind) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Brushes")
                .font(AtelierTypography.headline)
                .foregroundStyle(AtelierTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
                ForEach(BrushLibrary.all) { brush in
                    Button {
                        selectedBrush = brush
                        onSelect?(brush)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: brush.systemImage)
                                .font(.system(size: 20, weight: .semibold))
                            Text(brush.displayName)
                                .font(AtelierTypography.caption)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(AtelierTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedBrush == brush ? AtelierTheme.accentSoft : AtelierTheme.surfaceElevated)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(selectedBrush == brush ? AtelierTheme.accent : AtelierTheme.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(brush.displayName)
                    .accessibilityHint(brush.accessibilityHint)
                    .accessibilityAddTraits(selectedBrush == brush ? .isSelected : [])
                }
            }
        }
        .padding(16)
        .atelierPanel()
    }
}
