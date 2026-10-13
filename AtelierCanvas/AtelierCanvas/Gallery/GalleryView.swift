import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var artworkStore: ArtworkStore
    @EnvironmentObject private var navigation: AppNavigation
    @StateObject private var viewModel = GalleryViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 240), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AtelierTheme.background.ignoresSafeArea()

                if artworkStore.sortedArtworks.isEmpty {
                    EmptyGalleryView(onCreate: createAndOpen)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(artworkStore.sortedArtworks) { artwork in
                                ArtworkThumbnailView(
                                    artwork: artwork,
                                    image: artworkStore.thumbnailImage(for: artwork.id),
                                    onOpen: { navigation.openStudio(artworkID: artwork.id) },
                                    onRename: { viewModel.beginRename(artwork) },
                                    onExport: { viewModel.export(artwork, using: artworkStore) },
                                    onDelete: { viewModel.requestDelete(artwork) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Atelier Canvas")
                            .font(AtelierTypography.brand)
                            .foregroundStyle(AtelierTheme.textPrimary)
                        Text("Local digital painting studio")
                            .font(AtelierTypography.caption)
                            .foregroundStyle(AtelierTheme.textSecondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Atelier Canvas, local digital painting studio")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AtelierPrimaryButton("New Canvas", systemImage: "plus", action: createAndOpen)
                }
            }
            .alert("Rename Artwork", isPresented: Binding(
                get: { viewModel.renamingArtwork != nil },
                set: { if !$0 { viewModel.renamingArtwork = nil } }
            )) {
                TextField("Title", text: $viewModel.renameText)
                    .accessibilityLabel("Artwork title")
                Button("Save") { viewModel.commitRename(using: artworkStore) }
                Button("Cancel", role: .cancel) { viewModel.renamingArtwork = nil }
            }
            .alert("Delete Artwork?", isPresented: Binding(
                get: { viewModel.artworkPendingDelete != nil },
                set: { if !$0 { viewModel.artworkPendingDelete = nil } }
            )) {
                Button("Delete", role: .destructive) { viewModel.confirmDelete(using: artworkStore) }
                Button("Cancel", role: .cancel) { viewModel.artworkPendingDelete = nil }
            } message: {
                Text("“\(viewModel.artworkPendingDelete?.title ?? "This artwork")” will be removed from this device. This cannot be undone.")
            }
            .alert("Something went wrong", isPresented: Binding(
                get: { viewModel.alertMessage != nil || artworkStore.lastErrorMessage != nil },
                set: { if !$0 {
                    viewModel.alertMessage = nil
                    artworkStore.lastErrorMessage = nil
                }}
            )) {
                Button("OK", role: .cancel) {
                    viewModel.alertMessage = nil
                    artworkStore.lastErrorMessage = nil
                }
            } message: {
                Text(viewModel.alertMessage ?? artworkStore.lastErrorMessage ?? "Unknown error")
            }
            .sheet(isPresented: $viewModel.isSharing) {
                if let url = viewModel.exportURL {
                    ShareSheet(items: [url]) { _ in
                        viewModel.isSharing = false
                    }
                }
            }
        }
    }

    private func createAndOpen() {
        let artwork = artworkStore.createArtwork()
        navigation.openStudio(artworkID: artwork.id)
    }
}
