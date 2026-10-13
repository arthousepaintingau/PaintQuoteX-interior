import SwiftUI

@main
struct AtelierCanvasApp: App {
    @StateObject private var artworkStore = ArtworkStore()
    @StateObject private var navigation = AppNavigation()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(artworkStore)
                .environmentObject(navigation)
                .preferredColorScheme(.dark)
                .tint(AtelierTheme.accent)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .inactive || phase == .background {
                artworkStore.savePendingChanges()
            }
        }
    }
}
