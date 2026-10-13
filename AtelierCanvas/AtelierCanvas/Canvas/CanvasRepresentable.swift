import PencilKit
import SwiftUI
import UIKit

struct CanvasRepresentable: UIViewRepresentable {
    @ObservedObject var controller: CanvasController
    var onDrawingChanged: (PKDrawing) -> Void
    var isFingerDrawingEnabled: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = UIColor(AtelierTheme.canvasPaper)
        canvas.isOpaque = true
        canvas.drawingPolicy = isFingerDrawingEnabled ? .anyInput : .pencilOnly
        canvas.minimumZoomScale = 0.5
        canvas.maximumZoomScale = 6.0
        canvas.bouncesZoom = true
        canvas.delegate = context.coordinator
        canvas.tool = PKInkingTool(.pencil, color: .black, width: 8)
        canvas.contentSize = CGSize(width: 2048, height: 2048)
        canvas.alwaysBounceVertical = true
        canvas.alwaysBounceHorizontal = true
        canvas.isScrollEnabled = true
        canvas.showsVerticalScrollIndicator = false
        canvas.showsHorizontalScrollIndicator = false
        canvas.overrideUserInterfaceStyle = .light

        // Two-finger pan remains available via scroll view; Apple Pencil draws.
        // When finger drawing is on, pinch/pan still work via zoom gestures.
        controller.canvasView = canvas
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawingPolicy = isFingerDrawingEnabled ? .anyInput : .pencilOnly
        if controller.canvasView !== uiView {
            controller.canvasView = uiView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasRepresentable

        init(parent: CanvasRepresentable) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.controller.refreshUndoState()
            parent.onDrawingChanged(canvasView.drawing)
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            parent.controller.refreshUndoState()
        }
    }
}
