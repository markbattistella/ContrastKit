//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Public APIs

extension Color {

    /// Adjusts the color based on the specified level and optionally adjusts for the 
    /// specified color scheme.
    ///
    /// - Parameters:
    ///   - level: The specified `ColorLevel`.
    ///   - scheme: Optional `ColorScheme` to adjust for light or dark mode.
    /// - Returns: A `Color` adjusted for the specified level and color scheme.
    public func level(_ level: ColorLevel, scheme: ColorScheme? = nil) -> Color {
        let adjustedLevel = scheme == .dark ? level.correspondingDarkModeLevel : level
        let components = self.uiColorComponents()
        return Color.hsl(
            hue: components.hue * 360,
            saturation: components.saturation,
            lightness: adjustedLevel.lightness
        )
    }

    /// Returns the color that achieves the highest possible contrast.
    ///
    /// This property calculates the maximum contrast color available without any upper limit
    /// on the contrast ratio, aiming to enhance readability and accessibility.
    public var highestRatedContrastLevel: Color {
        calculateBestContrast(for: .aaa, maxRatio: CGFloat.infinity)
    }

    /// Direct access to a color that complies with the AAA contrast level requirements.
    public var aaaContrastLevel: Color {
        calculateBestContrast(for: .aaa)
    }

    /// Direct access to a color that complies with the AA contrast level requirements.
    public var aaContrastLevel: Color {
        calculateBestContrast(for: .aa)
    }

    /// Direct access to a color that complies with the AA Large contrast level requirements.
    public var aaLargeContrastLevel: Color {
        calculateBestContrast(for: .aaLarge)
    }
}
