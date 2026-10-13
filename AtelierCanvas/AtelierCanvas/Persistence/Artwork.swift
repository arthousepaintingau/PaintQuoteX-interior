import Foundation

struct Artwork: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var createdAt: Date
    var modifiedAt: Date
    var canvasWidth: Double
    var canvasHeight: Double

    var drawingFileName: String { "\(id.uuidString).drawing" }
    var thumbnailFileName: String { "\(id.uuidString).png" }

    init(
        id: UUID = UUID(),
        title: String = "Untitled",
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        canvasWidth: Double = 2048,
        canvasHeight: Double = 2048
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
    }

    mutating func rename(to newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        title = trimmed.isEmpty ? "Untitled" : trimmed
        modifiedAt = Date()
    }

    mutating func touchModified() {
        modifiedAt = Date()
    }
}

struct ArtworkLibrary: Codable, Equatable {
    var artworks: [Artwork]

    static let empty = ArtworkLibrary(artworks: [])
}
