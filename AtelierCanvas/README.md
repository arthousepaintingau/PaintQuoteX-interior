# Atelier Canvas

Native iOS digital painting studio built with Swift, SwiftUI, and PencilKit.

## Requirements

- Xcode 16+
- iOS 18.0+
- iPhone or iPad (Apple Pencil optional)

## Open & run

1. Open `AtelierCanvas.xcodeproj` in Xcode.
2. Select an iOS 18 simulator or device.
3. Set your development team under Signing & Capabilities if needed.
4. Run the **AtelierCanvas** scheme.

## Tests

```bash
xcodebuild test \
  -project AtelierCanvas.xcodeproj \
  -scheme AtelierCanvas \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

| Module | Responsibility |
| --- | --- |
| App | Entry, navigation, scene-phase saves |
| Gallery | Artwork grid, create/rename/delete |
| Studio | Drawing chrome, tools, export |
| Canvas | `PKCanvasView` bridge + undo/zoom |
| Brushes | Honest PencilKit brush presets |
| Colors | Wheel, presets, recent colours |
| Persistence | Metadata JSON + `.drawing` files |
| Thumbnails | Local PNG previews |
| Export | PNG export + share sheet |
| DesignSystem | Dark studio theme + controls |

Editable artwork data is stored in Application Support (`PKDrawing` files + `library.json`), not PNG-only.
