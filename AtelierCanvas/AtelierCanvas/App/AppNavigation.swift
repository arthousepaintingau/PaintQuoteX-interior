import Foundation
import SwiftUI

@MainActor
final class AppNavigation: ObservableObject {
    enum Route: Equatable {
        case gallery
        case studio(artworkID: UUID)
    }

    @Published var route: Route = .gallery

    func openStudio(artworkID: UUID) {
        route = .studio(artworkID: artworkID)
    }

    func returnToGallery() {
        route = .gallery
    }
}
