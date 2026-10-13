import Foundation
import PencilKit
import UIKit

/// Brush presets mapped to real PencilKit tools — no simulated paint engines.
enum BrushKind: String, CaseIterable, Identifiable, Codable {
    case pencil
    case fineLiner
    case inkPen
    case marker
    case softBrush
    case eraser

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pencil: return "Pencil"
        case .fineLiner: return "Fine liner"
        case .inkPen: return "Ink pen"
        case .marker: return "Marker"
        case .softBrush: return "Soft brush"
        case .eraser: return "Eraser"
        }
    }

    var systemImage: String {
        switch self {
        case .pencil: return "pencil.tip"
        case .fineLiner: return "pencil.line"
        case .inkPen: return "paintbrush.pointed"
        case .marker: return "highlighter"
        case .softBrush: return "paintbrush"
        case .eraser: return "eraser"
        }
    }

    var accessibilityHint: String {
        switch self {
        case .pencil:
            return "PencilKit pencil tool with pressure and tilt where supported"
        case .fineLiner:
            return "PencilKit monoline tool for precise lines"
        case .inkPen:
            return "PencilKit fountain pen tool"
        case .marker:
            return "PencilKit marker tool"
        case .softBrush:
            return "PencilKit watercolor tool for soft strokes"
        case .eraser:
            return "PencilKit vector eraser"
        }
    }

    var isEraser: Bool { self == .eraser }

    var defaultWidth: CGFloat {
        switch self {
        case .pencil: return 8
        case .fineLiner: return 3
        case .inkPen: return 6
        case .marker: return 18
        case .softBrush: return 28
        case .eraser: return 24
        }
    }

    var widthRange: ClosedRange<CGFloat> {
        switch self {
        case .pencil: return 2...30
        case .fineLiner: return 1...12
        case .inkPen: return 2...24
        case .marker: return 6...50
        case .softBrush: return 8...60
        case .eraser: return 8...60
        }
    }

    func makeTool(color: UIColor, width: CGFloat, opacity: CGFloat) -> PKTool {
        let clampedWidth = min(max(width, widthRange.lowerBound), widthRange.upperBound)
        let clampedOpacity = min(max(opacity, 0.05), 1.0)

        if self == .eraser {
            return PKEraserTool(.vector, width: clampedWidth)
        }

        let inkColor = color.withAlphaComponent(clampedOpacity)
        let inkType: PKInk.InkType
        switch self {
        case .pencil:
            inkType = .pencil
        case .fineLiner:
            inkType = .monoline
        case .inkPen:
            inkType = .fountainPen
        case .marker:
            inkType = .marker
        case .softBrush:
            inkType = .watercolor
        case .eraser:
            inkType = .pen
        }

        return PKInkingTool(inkType, color: inkColor, width: clampedWidth)
    }
}
