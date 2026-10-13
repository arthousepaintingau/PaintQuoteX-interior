import SwiftUI

struct StudioToolbar: View {
    @ObservedObject var viewModel: StudioViewModel
    let onBack: () -> Void
    let onExport: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            AtelierIconButton(systemImage: "chevron.left", label: "Back to gallery", action: onBack)

            AtelierIconButton(
                systemImage: "arrow.uturn.backward",
                label: "Undo",
                isEnabled: viewModel.canvasController.canUndo
            ) {
                viewModel.canvasController.undo()
            }

            AtelierIconButton(
                systemImage: "arrow.uturn.forward",
                label: "Redo",
                isEnabled: viewModel.canvasController.canRedo
            ) {
                viewModel.canvasController.redo()
            }

            Spacer(minLength: 8)

            AtelierIconButton(
                systemImage: viewModel.selectedBrush.systemImage,
                label: "Brush library, \(viewModel.selectedBrush.displayName)",
                isSelected: viewModel.showsBrushLibrary
            ) {
                viewModel.showsBrushLibrary.toggle()
                if viewModel.showsBrushLibrary { viewModel.showsColorPanel = false }
            }

            Button {
                viewModel.showsColorPanel.toggle()
                if viewModel.showsColorPanel { viewModel.showsBrushLibrary = false }
            } label: {
                Circle()
                    .fill(viewModel.selectedColor)
                    .frame(width: 22, height: 22)
                    .overlay(Circle().stroke(AtelierTheme.textPrimary.opacity(0.8), lineWidth: 1.5))
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(viewModel.showsColorPanel ? AtelierTheme.toolSelected : AtelierTheme.toolIdle)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Colour picker")
            .accessibilityValue("Selected colour")
            .disabled(viewModel.selectedBrush.isEraser)
            .opacity(viewModel.selectedBrush.isEraser ? 0.4 : 1)

            AtelierIconButton(
                systemImage: "hand.draw",
                label: viewModel.allowsFingerDrawing ? "Finger drawing on" : "Finger drawing off",
                isSelected: viewModel.allowsFingerDrawing
            ) {
                viewModel.allowsFingerDrawing.toggle()
                viewModel.canvasController.setAllowsFingerDrawing(viewModel.allowsFingerDrawing)
            }

            AtelierIconButton(systemImage: "square.and.arrow.up", label: "Export PNG", action: onExport)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AtelierTheme.border, lineWidth: 1)
        )
    }
}

struct StudioSliders: View {
    @ObservedObject var viewModel: StudioViewModel

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Size")
                    .font(AtelierTypography.caption)
                    .foregroundStyle(AtelierTheme.textSecondary)
                    .frame(width: 54, alignment: .leading)
                Slider(
                    value: $viewModel.brushSize,
                    in: viewModel.selectedBrush.widthRange
                ) { editing in
                    if !editing { viewModel.applyCurrentTool() }
                }
                .tint(AtelierTheme.accent)
                .accessibilityLabel("Brush size")
                Text("\(Int(viewModel.brushSize))")
                    .font(AtelierTypography.micro)
                    .foregroundStyle(AtelierTheme.textSecondary)
                    .frame(width: 28, alignment: .trailing)
            }

            HStack {
                Text("Opacity")
                    .font(AtelierTypography.caption)
                    .foregroundStyle(AtelierTheme.textSecondary)
                    .frame(width: 54, alignment: .leading)
                Slider(value: $viewModel.opacity, in: 0.05...1.0) { editing in
                    if !editing { viewModel.applyCurrentTool() }
                }
                .tint(AtelierTheme.accent)
                .disabled(viewModel.selectedBrush.isEraser)
                .accessibilityLabel("Brush opacity")
                Text("\(Int(viewModel.opacity * 100))%")
                    .font(AtelierTypography.micro)
                    .foregroundStyle(AtelierTheme.textSecondary)
                    .frame(width: 36, alignment: .trailing)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AtelierTheme.border, lineWidth: 1)
        )
        .onChange(of: viewModel.brushSize) { _, _ in
            viewModel.applyCurrentTool()
        }
        .onChange(of: viewModel.opacity) { _, _ in
            viewModel.applyCurrentTool()
        }
    }
}
