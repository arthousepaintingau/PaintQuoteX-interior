import Foundation

enum BrushLibrary {
    static let drawingBrushes: [BrushKind] = BrushKind.allCases.filter { !$0.isEraser }
    static let all: [BrushKind] = BrushKind.allCases
}
