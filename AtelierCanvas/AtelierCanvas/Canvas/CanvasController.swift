import Combine
import Foundation
import PencilKit
import UIKit

@MainActor
final class CanvasController: NSObject, ObservableObject {
    @Published var canUndo = false
    @Published var canRedo = false
    @Published var zoomScale: CGFloat = 1.0

    weak var canvasView: PKCanvasView? {
        didSet { refreshUndoState() }
    }

    private var undoObserver: NSObjectProtocol?
    private var redoObserver: NSObjectProtocol?

    override init() {
        super.init()
        undoObserver = NotificationCenter.default.addObserver(
            forName: .NSUndoManagerDidCloseUndoGroup,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refreshUndoState() }
        }
        redoObserver = NotificationCenter.default.addObserver(
            forName: .NSUndoManagerDidUndoChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refreshUndoState() }
        }
        NotificationCenter.default.addObserver(
            forName: .NSUndoManagerDidRedoChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refreshUndoState() }
        }
    }

    deinit {
        if let undoObserver { NotificationCenter.default.removeObserver(undoObserver) }
        if let redoObserver { NotificationCenter.default.removeObserver(redoObserver) }
    }

    func applyTool(_ tool: PKTool) {
        canvasView?.tool = tool
    }

    func setDrawing(_ drawing: PKDrawing) {
        canvasView?.drawing = drawing
        refreshUndoState()
    }

    func currentDrawing() -> PKDrawing {
        canvasView?.drawing ?? PKDrawing()
    }

    func undo() {
        canvasView?.undoManager?.undo()
        refreshUndoState()
    }

    func redo() {
        canvasView?.undoManager?.redo()
        refreshUndoState()
    }

    func refreshUndoState() {
        let manager = canvasView?.undoManager
        canUndo = manager?.canUndo ?? false
        canRedo = manager?.canRedo ?? false
        zoomScale = canvasView?.zoomScale ?? 1
    }

    func setAllowsFingerDrawing(_ allowed: Bool) {
        if #available(iOS 14.0, *) {
            canvasView?.drawingPolicy = allowed ? .anyInput : .pencilOnly
        }
    }
}
