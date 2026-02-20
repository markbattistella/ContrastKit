//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A `ShapeStyle` that applies a lightness level to a base colour and automatically
/// adapts to the current environment's colour scheme.
///
/// `ColorLevelStyle` defers colour scheme resolution to render time via
/// `ShapeStyle.resolve(in:)`, eliminating the need for `@Environment(\.colorScheme)`
/// at every call site.
///
/// ```swift
/// // No @Environment capture needed
/// Text("Hello").foregroundStyle(brandColor.level(.level300))
/// Text("World").foregroundStyle(brandColor.level700)
/// ```
public struct ColorLevelStyle: ShapeStyle {
    private let base: Color
    private let level: ColorLevel

    internal init(base: Color, level: ColorLevel) {
        self.base = base
        self.level = level
    }

    /// Resolves the colour for the given environment, automatically adjusting for the
    /// current colour scheme.
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        base.level(level, for: environment.colorScheme)
    }
}
