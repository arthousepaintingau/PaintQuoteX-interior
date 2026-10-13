import SwiftUI

struct AtelierPrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(AtelierTypography.headline)
            }
            .foregroundStyle(AtelierTheme.background)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(AtelierTheme.accent, in: RoundedRectangle(cornerRadius: AtelierTheme.compactCorner, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct AtelierIconButton: View {
    let systemImage: String
    let label: String
    var isEnabled: Bool = true
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isEnabled ? AtelierTheme.textPrimary : AtelierTheme.textSecondary.opacity(0.45))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? AtelierTheme.toolSelected : AtelierTheme.toolIdle)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct AtelierPanel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AtelierTheme.cornerRadius, style: .continuous)
                    .fill(AtelierTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AtelierTheme.cornerRadius, style: .continuous)
                            .stroke(AtelierTheme.border, lineWidth: 1)
                    )
            )
    }
}

extension View {
    func atelierPanel() -> some View {
        modifier(AtelierPanel())
    }
}
