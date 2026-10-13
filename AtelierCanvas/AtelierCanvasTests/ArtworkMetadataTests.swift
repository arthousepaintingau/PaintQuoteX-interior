import XCTest
@testable import AtelierCanvas

final class ArtworkMetadataTests: XCTestCase {
    func testArtworkIDsAreStableAndUnique() {
        let first = Artwork(title: "A")
        let second = Artwork(title: "B")
        XCTAssertNotEqual(first.id, second.id)
        XCTAssertEqual(first.drawingFileName, "\(first.id.uuidString).drawing")
        XCTAssertEqual(first.thumbnailFileName, "\(first.id.uuidString).png")
    }

    func testRenameTrimsAndFallsBackToUntitled() {
        var artwork = Artwork(title: "Canvas")
        let before = artwork.modifiedAt
        artwork.rename(to: "  Morning Study  ")
        XCTAssertEqual(artwork.title, "Morning Study")
        XCTAssertGreaterThanOrEqual(artwork.modifiedAt, before)

        artwork.rename(to: "   ")
        XCTAssertEqual(artwork.title, "Untitled")
    }

    func testLibraryCodableRoundTrip() throws {
        let library = ArtworkLibrary(artworks: [
            Artwork(title: "One"),
            Artwork(title: "Two")
        ])
        let data = try JSONEncoder().encode(library)
        let decoded = try JSONDecoder().decode(ArtworkLibrary.self, from: data)
        XCTAssertEqual(decoded.artworks.count, 2)
        XCTAssertEqual(decoded.artworks[0].title, "One")
        XCTAssertEqual(decoded.artworks[1].id, library.artworks[1].id)
    }

    func testExportFileNameSanitization() {
        XCTAssertEqual(ArtworkExporter.sanitizedFileName("  Soft Rain  "), "Soft-Rain")
        XCTAssertEqual(ArtworkExporter.sanitizedFileName(""), "Artwork")
        XCTAssertEqual(ArtworkExporter.sanitizedFileName("A/B:C*"), "A-B-C-")
    }
}
