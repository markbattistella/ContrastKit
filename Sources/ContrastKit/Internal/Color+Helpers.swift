//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Internal APIs

@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
extension Color {

    /// Creates a color from specified HSL (Hue, Saturation, Lightness) components.
    ///
    /// The method calculates the corresponding RGB values using the HSL color model and
    /// returns a SwiftUI Color.
    ///
    /// - Parameters:
    ///   - hue: The hue component of the color, specified in degrees.
    ///   - saturation: The saturation of the color, specified as a fraction from 0.0 to 1.0.
    ///   - lightness: The lightness of the color, specified as a fraction from 0.0 to 1.0.
    /// - Returns: A SwiftUI Color object with the specified HSL values.
    internal static func hsl(
        hue: CGFloat,
        saturation: CGFloat,
        lightness: CGFloat
    ) -> Color {
        let c = (1 - abs(2 * lightness - 1)) * saturation
        let x = c * (1 - abs(fmod(hue / 60.0, 2) - 1))
        let m = lightness - c / 2

        let (r, g, b) = hueToRGB(hue: hue, c: c, x: x, m: m)
        return Color(red: Double(r), green: Double(g), blue: Double(b))
    }

    /// Retrieves and returns the HSL components of the color.
    ///
    /// This method uses the UIKit method to extract hue, saturation, and brightness
    /// values, then returns them as a tuple. Note that `brightness` in UIKit corresponds
    /// to `lightness` in HSL.
    ///
    /// - Returns: A tuple containing the hue, saturation, and lightness (brightness in UIKit)
    /// of the color.
    internal func uiColorComponents() -> (hue: CGFloat, saturation: CGFloat, lightness: CGFloat) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        AgnosticColor(self).getHue(&hue,
                            saturation: &saturation,
                            brightness: &brightness,
                            alpha: nil)
        return (hue, saturation, brightness)
    }

    /// Calculates the color that provides the best contrast according to the specified
    /// contrast level settings.
    ///
    /// This method calculates the best contrast by evaluating all potential candidate colors
    /// and selecting the one that offers the highest contrast without exceeding the specified
    /// maximum ratio.
    ///
    /// - Parameters:
    ///   - level: The contrast level to calculate.
    ///   - maxRatio: The optional maximum contrast ratio to consider. If nil, there's no
    ///   upper limit.
    /// - Returns: The `Color` that provides the best contrast.
    internal func calculateBestContrast(
        for level: ContrastLevel,
        maxRatio: CGFloat? = nil
    ) -> Color {
        let backgroundLuminance = AgnosticColor(self).luminance()
        var bestContrastColor: Color = .white
        var bestContrastRatio: CGFloat = 0
        let candidateColors = [Color.white, Color.black] + ColorLevel.allCases.map { self.level($0) }
        let (minRatio, upperLimit) = (level.ratio.min, maxRatio ?? level.ratio.max)
        for candidate in candidateColors {
            let candidateLuminance = AgnosticColor(candidate).luminance()
            let contrastRatio = (max(backgroundLuminance, candidateLuminance) + 0.05) /
            (min(backgroundLuminance, candidateLuminance) + 0.05)
            if contrastRatio >= minRatio
                && contrastRatio <= upperLimit
                && contrastRatio > bestContrastRatio {
                bestContrastRatio = contrastRatio
                bestContrastColor = candidate
            }
        }
        return bestContrastColor
    }
}

// MARK: - Private APIs

@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
extension Color {

    /// Converts hue value to RGB components.
    ///
    /// This function supports the conversion by determining which segment
    /// of the color wheel the hue lies within, and adjusts the RGB values accordingly.
    ///
    /// - Parameters:
    ///   - hue: The hue component of the color.
    ///   - c: The color value.
    ///   - x: The secondary color value.
    ///   - m: The base value for RGB components.
    /// - Returns: The RGB components as a tuple.
    private static func hueToRGB(
        hue: CGFloat,
        c: CGFloat,
        x: CGFloat,
        m: CGFloat
    ) -> (CGFloat, CGFloat, CGFloat) {
        switch Int(hue / 60.0) % 6 {
            case 0: (c + m, x + m, m)
            case 1: (x + m, c + m, m)
            case 2: (m, c + m, x + m)
            case 3: (m, x + m, c + m)
            case 4: (x + m, m, c + m)
            case 5: (c + m, m, x + m)
            default: (m, m, m)
        }
    }
}
