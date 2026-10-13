import Foundation
import PencilKit
import UIKit

struct ThumbnailGenerator {
    let directoryURL: URL
    private let thumbnailSize = CGSize(width: 512, height: 512)

    func fileURL(for artworkID: UUID) -> URL {
        directoryURL.appendingPathComponent("\(artworkID.uuidString).png", isDirectory: false)
    }

    func save(drawing: PKDrawing, for artworkID: UUID) throws {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let bounds = drawing.bounds.isNull || drawing.bounds.isEmpty
            ? CGRect(origin: .zero, size: thumbnailSize)
            : drawing.bounds.insetBy(dx: -40, dy: -40)
        let image = drawing.image(from: bounds, scale: 2.0)
        let rendered = renderThumbnail(from: image)
        guard let data = rendered.pngData() else {
            throw ThumbnailError.encodingFailed
        }
        try data.write(to: fileURL(for: artworkID), options: [.atomic])
    }

    func saveBlankThumbnail(for artworkID: UUID) throws {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
        let image = renderer.image { context in
            UIColor(red: 0.98, green: 0.98, blue: 0.97, alpha: 1).setFill()
            context.fill(CGRect(origin: .zero, size: thumbnailSize))
        }
        guard let data = image.pngData() else {
            throw ThumbnailError.encodingFailed
        }
        try data.write(to: fileURL(for: artworkID), options: [.atomic])
    }

    func load(for artworkID: UUID) -> UIImage? {
        let url = fileURL(for: artworkID)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    func delete(for artworkID: UUID) throws {
        let url = fileURL(for: artworkID)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    private func renderThumbnail(from image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
        return renderer.image { _ in
            UIColor(red: 0.98, green: 0.98, blue: 0.97, alpha: 1).setFill()
            UIRectFill(CGRect(origin: .zero, size: thumbnailSize))

            let aspect = min(
                thumbnailSize.width / max(image.size.width, 1),
                thumbnailSize.height / max(image.size.height, 1)
            )
            let drawSize = CGSize(width: image.size.width * aspect, height: image.size.height * aspect)
            let origin = CGPoint(
                x: (thumbnailSize.width - drawSize.width) / 2,
                y: (thumbnailSize.height - drawSize.height) / 2
            )
            image.draw(in: CGRect(origin: origin, size: drawSize))
        }
    }
}

enum ThumbnailError: LocalizedError {
    case encodingFailed

    var errorDescription: String? {
        "Could not create artwork thumbnail."
    }
}
