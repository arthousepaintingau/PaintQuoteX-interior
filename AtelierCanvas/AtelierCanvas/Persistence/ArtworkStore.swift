import Foundation
import PencilKit
import UIKit

@MainActor
final class ArtworkStore: ObservableObject {
    @Published private(set) var artworks: [Artwork] = []
    @Published var lastErrorMessage: String?

    private let fileManager: FileManager
    private let rootURL: URL
    private let libraryURL: URL
    private let drawingsURL: URL
    private let thumbnailsURL: URL
    private let drawingStore: DrawingFileStore
    private let thumbnailGenerator: ThumbnailGenerator
    private var pendingDrawingSaves: [UUID: PKDrawing] = [:]
    private var autosaveTask: Task<Void, Never>?

    init(preview: Bool = false, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        if preview {
            let temporary = fileManager.temporaryDirectory.appendingPathComponent("AtelierCanvasPreview-\(UUID().uuidString)", isDirectory: true)
            self.rootURL = temporary
        } else {
            let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            self.rootURL = support.appendingPathComponent("AtelierCanvas", isDirectory: true)
        }
        self.libraryURL = rootURL.appendingPathComponent("library.json", isDirectory: false)
        self.drawingsURL = rootURL.appendingPathComponent("Drawings", isDirectory: true)
        self.thumbnailsURL = rootURL.appendingPathComponent("Thumbnails", isDirectory: true)
        self.drawingStore = DrawingFileStore(directoryURL: drawingsURL)
        self.thumbnailGenerator = ThumbnailGenerator(directoryURL: thumbnailsURL)

        if !preview {
            prepareDirectories()
            loadLibrary()
        }
    }

    /// Test seam that uses an isolated directory.
    init(rootURL: URL, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.rootURL = rootURL
        self.libraryURL = rootURL.appendingPathComponent("library.json", isDirectory: false)
        self.drawingsURL = rootURL.appendingPathComponent("Drawings", isDirectory: true)
        self.thumbnailsURL = rootURL.appendingPathComponent("Thumbnails", isDirectory: true)
        self.drawingStore = DrawingFileStore(directoryURL: drawingsURL)
        self.thumbnailGenerator = ThumbnailGenerator(directoryURL: thumbnailsURL)
        prepareDirectories()
        loadLibrary()
    }

    var sortedArtworks: [Artwork] {
        artworks.sorted { $0.modifiedAt > $1.modifiedAt }
    }

    func artwork(id: UUID) -> Artwork? {
        artworks.first { $0.id == id }
    }

    @discardableResult
    func createArtwork(title: String = "Untitled") -> Artwork {
        let artwork = Artwork(title: title)
        artworks.insert(artwork, at: 0)
        persistLibrary()
        do {
            try drawingStore.save(PKDrawing(), for: artwork.id)
            try thumbnailGenerator.saveBlankThumbnail(for: artwork.id)
        } catch {
            lastErrorMessage = error.localizedDescription
        }
        return artwork
    }

    func renameArtwork(id: UUID, to title: String) {
        guard let index = artworks.firstIndex(where: { $0.id == id }) else { return }
        artworks[index].rename(to: title)
        persistLibrary()
    }

    func deleteArtwork(id: UUID) {
        artworks.removeAll { $0.id == id }
        pendingDrawingSaves.removeValue(forKey: id)
        persistLibrary()
        do {
            try drawingStore.delete(for: id)
            try thumbnailGenerator.delete(for: id)
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func loadDrawing(for artworkID: UUID) -> PKDrawing {
        do {
            if let pending = pendingDrawingSaves[artworkID] {
                return pending
            }
            return try drawingStore.load(for: artworkID)
        } catch {
            lastErrorMessage = error.localizedDescription
            return PKDrawing()
        }
    }

    func noteDrawingChange(_ drawing: PKDrawing, for artworkID: UUID) {
        pendingDrawingSaves[artworkID] = drawing
        if let index = artworks.firstIndex(where: { $0.id == artworkID }) {
            artworks[index].touchModified()
        }
        scheduleAutosave(for: artworkID)
    }

    func savePendingChanges() {
        autosaveTask?.cancel()
        let snapshot = pendingDrawingSaves
        for (id, drawing) in snapshot {
            commit(drawing: drawing, artworkID: id)
        }
    }

    func saveNow(drawing: PKDrawing, artworkID: UUID) {
        pendingDrawingSaves[artworkID] = drawing
        commit(drawing: drawing, artworkID: artworkID)
    }

    func thumbnailImage(for artworkID: UUID) -> UIImage? {
        thumbnailGenerator.load(for: artworkID)
    }

    func thumbnailURL(for artworkID: UUID) -> URL {
        thumbnailGenerator.fileURL(for: artworkID)
    }

    func exportPNG(for artworkID: UUID, scale: CGFloat = 2.0) throws -> URL {
        let drawing = loadDrawing(for: artworkID)
        guard let artwork = artwork(id: artworkID) else {
            throw ArtworkExporterError.artworkMissing
        }
        return try ArtworkExporter.exportPNG(
            drawing: drawing,
            artwork: artwork,
            scale: scale
        )
    }

    // MARK: - Private

    private func prepareDirectories() {
        do {
            try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: drawingsURL, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: thumbnailsURL, withIntermediateDirectories: true)
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    private func loadLibrary() {
        guard fileManager.fileExists(atPath: libraryURL.path) else {
            artworks = []
            return
        }
        do {
            let data = try Data(contentsOf: libraryURL)
            let library = try JSONDecoder().decode(ArtworkLibrary.self, from: data)
            artworks = library.artworks
        } catch {
            lastErrorMessage = error.localizedDescription
            artworks = []
        }
    }

    private func persistLibrary() {
        do {
            let data = try JSONEncoder().encode(ArtworkLibrary(artworks: artworks))
            try data.write(to: libraryURL, options: [.atomic])
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    private func scheduleAutosave(for artworkID: UUID) {
        autosaveTask?.cancel()
        autosaveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled, let self else { return }
            if let drawing = self.pendingDrawingSaves[artworkID] {
                self.commit(drawing: drawing, artworkID: artworkID)
            }
        }
    }

    private func commit(drawing: PKDrawing, artworkID: UUID) {
        do {
            try drawingStore.save(drawing, for: artworkID)
            try thumbnailGenerator.save(drawing: drawing, for: artworkID)
            pendingDrawingSaves.removeValue(forKey: artworkID)
            persistLibrary()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }
}
