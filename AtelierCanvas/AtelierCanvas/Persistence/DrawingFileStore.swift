import Foundation
import PencilKit

enum DrawingFileStoreError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case ioFailed(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Could not encode drawing data."
        case .decodingFailed:
            return "Could not decode drawing data."
        case .ioFailed(let message):
            return message
        }
    }
}

struct DrawingFileStore {
    let directoryURL: URL

    init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    func fileURL(for artworkID: UUID) -> URL {
        directoryURL.appendingPathComponent("\(artworkID.uuidString).drawing", isDirectory: false)
    }

    func save(_ drawing: PKDrawing, for artworkID: UUID) throws {
        let data = drawing.dataRepresentation()
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            try data.write(to: fileURL(for: artworkID), options: [.atomic])
        } catch {
            throw DrawingFileStoreError.ioFailed(error.localizedDescription)
        }
    }

    func load(for artworkID: UUID) throws -> PKDrawing {
        let url = fileURL(for: artworkID)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return PKDrawing()
        }
        do {
            let data = try Data(contentsOf: url)
            return try PKDrawing(data: data)
        } catch {
            throw DrawingFileStoreError.decodingFailed
        }
    }

    func delete(for artworkID: UUID) throws {
        let url = fileURL(for: artworkID)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw DrawingFileStoreError.ioFailed(error.localizedDescription)
        }
    }

    /// Round-trip helper used by unit tests without requiring UIKit rendering.
    static func roundTripData(_ drawing: PKDrawing) throws -> Data {
        let data = drawing.dataRepresentation()
        let restored = try PKDrawing(data: data)
        return restored.dataRepresentation()
    }
}
