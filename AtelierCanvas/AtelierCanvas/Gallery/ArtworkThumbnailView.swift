import SwiftUI
import UIKit

struct ArtworkThumbnailView: View {
    let artwork: Artwork
    let image: UIImage?
    let onOpen: () -> Void
    let onRename: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AtelierTheme.canvasPaper)
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AtelierTheme.border, lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(artwork.title)
                        .font(AtelierTypography.headline)
                        .foregroundStyle(AtelierTheme.textPrimary)
                        .lineLimit(1)
                    Text(artwork.modifiedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(AtelierTypography.caption)
                        .foregroundStyle(AtelierTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .atelierPanel()
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Open", systemImage: "arrow.up.left.and.arrow.down.right", action: onOpen)
            Button("Rename", systemImage: "pencil", action: onRename)
            Button("Export PNG", systemImage: "square.and.arrow.up", action: onExport)
            Divider()
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(artwork.title), modified \(artwork.modifiedAt.formatted())")
        .accessibilityHint("Opens artwork in the studio")
        .accessibilityAction(named: "Rename", onRename)
        .accessibilityAction(named: "Export PNG", onExport)
        .accessibilityAction(named: "Delete", onDelete)
    }
}
