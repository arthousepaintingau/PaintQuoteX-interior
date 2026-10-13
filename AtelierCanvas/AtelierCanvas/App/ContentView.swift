import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigation: AppNavigation
    @EnvironmentObject private var artworkStore: ArtworkStore

    var body: some View {
        ZStack {
            AtelierTheme.background.ignoresSafeArea()

            switch navigation.route {
            case .gallery:
                GalleryView()
                    .transition(.opacity)
            case .studio(let artworkID):
                if let artwork = artworkStore.artwork(id: artworkID) {
                    StudioView(artwork: artwork)
                        .transition(.opacity)
                } else {
                    GalleryView()
                        .onAppear { navigation.returnToGallery() }
                }
            }
        }
        .animation(.easeInOut(duration: 0.22), value: navigation.route)
    }
}

#Preview {
    ContentView()
        .environmentObject(ArtworkStore(preview: true))
        .environmentObject(AppNavigation())
}
