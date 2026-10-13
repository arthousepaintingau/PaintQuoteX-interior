import XCTest
import PencilKit
import UIKit
@testable import AtelierCanvas

final class DrawingDataTests: XCTestCase {
    func testEmptyDrawingRoundTrip() throws {
        let drawing = PKDrawing()
        let data = try DrawingFileStore.roundTripData(drawing)
        let restored = try PKDrawing(data: data)
        XCTAssertTrue(restored.strokes.isEmpty)
        XCTAssertEqual(restored.dataRepresentation(), drawing.dataRepresentation())
    }

    func testDrawingFileStoreSaveLoadDelete() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DrawingStore-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = DrawingFileStore(directoryURL: directory)
        let id = UUID()
        let drawing = PKDrawing()

        try store.save(drawing, for: id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.fileURL(for: id).path))

        let loaded = try store.load(for: id)
        XCTAssertEqual(loaded.dataRepresentation(), drawing.dataRepresentation())

        try store.delete(for: id)
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.fileURL(for: id).path))

        let missing = try store.load(for: id)
        XCTAssertTrue(missing.strokes.isEmpty)
    }

    func testBrushKindProducesPencilKitTools() {
        let color = UIColor.black
        for brush in BrushKind.allCases {
            let tool = brush.makeTool(color: color, width: brush.defaultWidth, opacity: 1)
            if brush.isEraser {
                XCTAssertTrue(tool is PKEraserTool, "Expected eraser for \(brush.displayName)")
            } else {
                XCTAssertTrue(tool is PKInkingTool, "Expected inking tool for \(brush.displayName)")
            }
        }
    }
}
