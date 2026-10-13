import XCTest
import PencilKit
@testable import AtelierCanvas

@MainActor
final class ArtworkStoreTests: XCTestCase {
    private var rootURL: URL!
    private var store: ArtworkStore!

    override func setUp() async throws {
        try await super.setUp()
        rootURL = FileManager.default.temporaryDirectory.appendingPathComponent("AtelierCanvasTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        store = ArtworkStore(rootURL: rootURL)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: rootURL)
        store = nil
        rootURL = nil
        try await super.tearDown()
    }

    func testCreateArtworkPersistsMetadataAndDrawingFile() throws {
        let artwork = store.createArtwork(title: "Sketch One")
        XCTAssertEqual(store.artworks.count, 1)
        XCTAssertEqual(artwork.title, "Sketch One")

        let drawingURL = rootURL
            .appendingPathComponent("Drawings", isDirectory: true)
            .appendingPathComponent("\(artwork.id.uuidString).drawing")
        XCTAssertTrue(FileManager.default.fileExists(atPath: drawingURL.path))

        let libraryURL = rootURL.appendingPathComponent("library.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: libraryURL.path))
    }

    func testRenameAndDeleteArtwork() throws {
        let artwork = store.createArtwork(title: "Old")
        store.renameArtwork(id: artwork.id, to: "  New Title  ")
        XCTAssertEqual(store.artwork(id: artwork.id)?.title, "New Title")

        store.deleteArtwork(id: artwork.id)
        XCTAssertNil(store.artwork(id: artwork.id))
        XCTAssertTrue(store.artworks.isEmpty)

        let drawingURL = rootURL
            .appendingPathComponent("Drawings", isDirectory: true)
            .appendingPathComponent("\(artwork.id.uuidString).drawing")
        XCTAssertFalse(FileManager.default.fileExists(atPath: drawingURL.path))
    }

    func testDrawingSaveRoundTrip() throws {
        let artwork = store.createArtwork()
        let empty = store.loadDrawing(for: artwork.id)
        XCTAssertTrue(empty.strokes.isEmpty)

        // Persist empty drawing data through the store commit path.
        store.saveNow(drawing: PKDrawing(), artworkID: artwork.id)
        let reloaded = store.loadDrawing(for: artwork.id)
        XCTAssertEqual(reloaded.dataRepresentation(), empty.dataRepresentation())
    }
}
