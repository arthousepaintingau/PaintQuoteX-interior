import SwiftUI

struct EmptyGalleryView: View {
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 40)
            Image(systemName: "paintpalette")
                .font(.system(size: 42, weight: .light))
                .foregroundStyle(AtelierTheme.accent)
                .accessibilityHidden(true)
            Text("Your studio is empty")
                .font(AtelierTypography.title)
                .foregroundStyle(AtelierTheme.textPrimary)
            Text("Start a new canvas and keep editable PencilKit drawings on this device.")
                .font(AtelierTypography.body)
                .foregroundStyle(AtelierTheme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
            AtelierPrimaryButton("New Canvas", systemImage: "plus") {
                onCreate()
            }
            .accessibilityHint("Creates a new local artwork")
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
