import Foundation
import SwiftUI

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var renamingArtwork: Artwork?
    @Published var renameText = ""
    @Published var artworkPendingDelete: Artwork?
    @Published var exportURL: URL?
    @Published var isSharing = false
    @Published var alertMessage: String?

    func beginRename(_ artwork: Artwork) {
        renamingArtwork = artwork
        renameText = artwork.title
    }

    func commitRename(using store: ArtworkStore) {
        guard let artwork = renamingArtwork else { return }
        store.renameArtwork(id: artwork.id, to: renameText)
        renamingArtwork = nil
        renameText = ""
    }

    func requestDelete(_ artwork: Artwork) {
        artworkPendingDelete = artwork
    }

    func confirmDelete(using store: ArtworkStore) {
        guard let artwork = artworkPendingDelete else { return }
        store.deleteArtwork(id: artwork.id)
        artworkPendingDelete = nil
    }

    func export(_ artwork: Artwork, using store: ArtworkStore) {
        do {
            let url = try store.exportPNG(for: artwork.id)
            exportURL = url
            isSharing = true
        } catch {
            alertMessage = error.localizedDescription
        }
    }
}
