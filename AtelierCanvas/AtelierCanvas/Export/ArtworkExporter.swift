import Foundation
import PencilKit
import UIKit

enum ArtworkExporterError: LocalizedError {
    case artworkMissing
    case encodingFailed
    case writeFailed(String)

    var errorDescription: String? {
        switch self {
        case .artworkMissing:
            return "Artwork could not be found."
        case .encodingFailed:
            return "Could not create a PNG export."
        case .writeFailed(let message):
            return message
        }
    }
}

enum ArtworkExporter {
    static func exportPNG(drawing: PKDrawing, artwork: Artwork, scale: CGFloat = 2.0) throws -> URL {
        let size = CGSize(width: artwork.canvasWidth, height: artwork.canvasHeight)
        let bounds: CGRect
        if drawing.bounds.isNull || drawing.bounds.isEmpty {
            bounds = CGRect(origin: .zero, size: size)
        } else {
            let drawingBounds = drawing.bounds.insetBy(dx: -20, dy: -20)
            bounds = drawingBounds.union(CGRect(origin: .zero, size: size))
        }

        let image = drawing.image(from: bounds, scale: scale)
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let composed = renderer.image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: image.size))
            image.draw(at: .zero)
        }

        guard let data = composed.pngData() else {
            throw ArtworkExporterError.encodingFailed
        }

        let fileName = sanitizedFileName(artwork.title) + ".png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName, isDirectory: false)
        do {
            try data.write(to: url, options: [.atomic])
            return url
        } catch {
            throw ArtworkExporterError.writeFailed(error.localizedDescription)
        }
    }

    static func sanitizedFileName(_ title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.isEmpty ? "Artwork" : trimmed
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        let filtered = base.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        return String(filtered).replacingOccurrences(of: " ", with: "-")
    }
}
