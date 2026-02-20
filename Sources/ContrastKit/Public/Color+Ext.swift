//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Public APIs

@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
extension Color {

    /// Returns an environment-aware style at the specified lightness level.
    ///
    /// The level is automatically mirrored for dark mode — no `@Environment` capture needed.
    /// Use this in any SwiftUI context that accepts a `ShapeStyle`:
    ///
    /// ```swift
    /// Text("Hello").foregroundStyle(brandColor.level(.level300))
    /// Rectangle().fill(brandColor.level(.level900))
    /// ```
    ///
    /// - Parameter level: The lightness level to apply.
    /// - Returns: A `ColorLevelStyle` that adapts to the current colour scheme at render time.
    public func level(_ level: ColorLevel) -> ColorLevelStyle {
        ColorLevelStyle(base: self, level: level)
    }

    /// Returns a resolved `Color` at the specified lightness level, adjusted for the given
    /// colour scheme.
    ///
    /// Use this overload when you need a concrete `Color` value — for example, to store it,
    /// compare luminance, or pass it to a non-SwiftUI API.
    ///
    /// ```swift
    /// let darkVariant = brandColor.level(.level300, for: .dark)
    /// ```
    ///
    /// - Parameters:
    ///   - level: The lightness level to apply.
    ///   - scheme: The colour scheme to resolve against.
    /// - Returns: A resolved `Color`.
    public func level(_ level: ColorLevel, for scheme: ColorScheme) -> Color {
        let adjustedLevel = scheme == .dark ? level.correspondingDarkModeLevel : level
        let components = self.uiColorComponents()
        return Color.hsl(
            hue: components.hue * 360,
            saturation: components.saturation,
            lightness: adjustedLevel.lightness
        )
    }

    /// Returns the colour that achieves the highest possible contrast.
    ///
    /// This property calculates the maximum contrast colour available without any upper limit
    /// on the contrast ratio, aiming to enhance readability and accessibility.
    public var highestRatedContrastLevel: Color {
        calculateBestContrast(for: .aaa, maxRatio: CGFloat.infinity)
    }

    /// Direct access to a colour that complies with the AAA contrast level requirements.
    public var aaaContrastLevel: Color {
        calculateBestContrast(for: .aaa)
    }

    /// Direct access to a colour that complies with the AA contrast level requirements.
    public var aaContrastLevel: Color {
        calculateBestContrast(for: .aa)
    }

    /// Direct access to a colour that complies with the AA Large contrast level requirements.
    public var aaLargeContrastLevel: Color {
        calculateBestContrast(for: .aaLarge)
    }
}
