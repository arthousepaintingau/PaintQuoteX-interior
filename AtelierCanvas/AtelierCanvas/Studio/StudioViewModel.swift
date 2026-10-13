import Foundation
import PencilKit
import SwiftUI
import UIKit

@MainActor
final class StudioViewModel: ObservableObject {
    @Published var selectedBrush: BrushKind = .pencil
    @Published var selectedColor: Color = Color(red: 0.05, green: 0.05, blue: 0.06)
    @Published var brushSize: CGFloat = BrushKind.pencil.defaultWidth
    @Published var opacity: CGFloat = 1.0
    @Published var showsBrushLibrary = false
    @Published var showsColorPanel = false
    @Published var allowsFingerDrawing = true
    @Published var exportURL: URL?
    @Published var isSharing = false
    @Published var alertMessage: String?

    let artworkID: UUID
    let canvasController = CanvasController()
    let recentColors = RecentColorsStore()

    private var didLoadDrawing = false

    init(artworkID: UUID) {
        self.artworkID = artworkID
        brushSize = selectedBrush.defaultWidth
    }

    func loadIfNeeded(using store: ArtworkStore) {
        guard !didLoadDrawing else { return }
        let drawing = store.loadDrawing(for: artworkID)
        canvasController.setDrawing(drawing)
        applyCurrentTool()
        didLoadDrawing = true
    }

    func selectBrush(_ brush: BrushKind) {
        selectedBrush = brush
        brushSize = min(max(brushSize, brush.widthRange.lowerBound), brush.widthRange.upperBound)
        if brushSize == 0 || !brush.widthRange.contains(brushSize) {
            brushSize = brush.defaultWidth
        }
        applyCurrentTool()
        showsBrushLibrary = false
    }

    func applyCurrentTool() {
        let tool = selectedBrush.makeTool(
            color: ColorSystem.uiColor(from: selectedColor),
            width: brushSize,
            opacity: opacity
        )
        canvasController.applyTool(tool)
    }

    func handleDrawingChange(_ drawing: PKDrawing, store: ArtworkStore) {
        store.noteDrawingChange(drawing, for: artworkID)
        canvasController.refreshUndoState()
    }

    func saveAndLeave(store: ArtworkStore, navigation: AppNavigation) {
        store.saveNow(drawing: canvasController.currentDrawing(), artworkID: artworkID)
        navigation.returnToGallery()
    }

    func export(using store: ArtworkStore) {
        store.saveNow(drawing: canvasController.currentDrawing(), artworkID: artworkID)
        do {
            exportURL = try store.exportPNG(for: artworkID)
            isSharing = true
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func rememberColor() {
        recentColors.remember(selectedColor)
        applyCurrentTool()
    }
}
