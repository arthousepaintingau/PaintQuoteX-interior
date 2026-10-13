import SwiftUI

struct StudioView: View {
    @EnvironmentObject private var artworkStore: ArtworkStore
    @EnvironmentObject private var navigation: AppNavigation
    @Environment(\.scenePhase) private var scenePhase

    let artwork: Artwork
    @StateObject private var viewModel: StudioViewModel

    init(artwork: Artwork) {
        self.artwork = artwork
        _viewModel = StateObject(wrappedValue: StudioViewModel(artworkID: artwork.id))
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AtelierTheme.background.ignoresSafeArea()

                CanvasRepresentable(
                    controller: viewModel.canvasController,
                    onDrawingChanged: { drawing in
                        viewModel.handleDrawingChange(drawing, store: artworkStore)
                    },
                    isFingerDrawingEnabled: viewModel.allowsFingerDrawing
                )
                .ignoresSafeArea(edges: .bottom)
                .accessibilityLabel("Drawing canvas")
                .accessibilityHint("Draw with Apple Pencil or touch when finger drawing is enabled. Pinch to zoom, drag to pan.")

                VStack(spacing: 10) {
                    StudioToolbar(
                        viewModel: viewModel,
                        onBack: {
                            viewModel.saveAndLeave(store: artworkStore, navigation: navigation)
                        },
                        onExport: {
                            viewModel.export(using: artworkStore)
                        }
                    )
                    .padding(.horizontal, 12)

                    HStack {
                        Text(currentTitle)
                            .font(AtelierTypography.caption)
                            .foregroundStyle(AtelierTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .accessibilityLabel("Artwork title \(currentTitle)")
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    Spacer()

                    if viewModel.showsBrushLibrary {
                        BrushPickerView(selectedBrush: $viewModel.selectedBrush) { brush in
                            viewModel.selectBrush(brush)
                        }
                        .padding(.horizontal, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if viewModel.showsColorPanel && !viewModel.selectedBrush.isEraser {
                        ColorPickerPanel(
                            selectedColor: $viewModel.selectedColor,
                            recentColors: viewModel.recentColors
                        ) { _ in
                            viewModel.rememberColor()
                        }
                        .padding(.horizontal, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    StudioSliders(viewModel: viewModel)
                        .padding(.horizontal, 12)
                        .padding(.bottom, max(proxy.safeAreaInsets.bottom, 10))
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.showsBrushLibrary)
                .animation(.easeInOut(duration: 0.2), value: viewModel.showsColorPanel)
            }
        }
        .onAppear {
            viewModel.loadIfNeeded(using: artworkStore)
            viewModel.canvasController.setAllowsFingerDrawing(viewModel.allowsFingerDrawing)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .inactive || phase == .background {
                artworkStore.saveNow(
                    drawing: viewModel.canvasController.currentDrawing(),
                    artworkID: artwork.id
                )
            }
        }
        .onDisappear {
            artworkStore.saveNow(
                drawing: viewModel.canvasController.currentDrawing(),
                artworkID: artwork.id
            )
        }
        .sheet(isPresented: $viewModel.isSharing) {
            if let url = viewModel.exportURL {
                ShareSheet(items: [url]) { _ in
                    viewModel.isSharing = false
                }
            }
        }
        .alert("Export failed", isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.alertMessage = nil }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .statusBarHidden(false)
    }

    private var currentTitle: String {
        artworkStore.artwork(id: artwork.id)?.title ?? artwork.title
    }
}
