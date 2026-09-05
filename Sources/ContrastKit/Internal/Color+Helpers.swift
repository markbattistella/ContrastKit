//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Internal APIs

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

    /// Retrieves and returns the true HSL components of the color.
    ///
    /// Converts the color to sRGB and derives hue, saturation, and lightness directly from
    /// those components — this is a genuine RGB→HSL conversion, not UIKit's HSB (`getHue`),
    /// which uses a different lightness axis than HSL (pure red is HSB `(0°, 1.0, 1.0)` but
    /// HSL `(0°, 1.0, 0.5)`).
    ///
    /// - Returns: A tuple containing the hue (degrees, `0..<360`), saturation, and lightness
    /// of the color.
    internal func uiColorComponents() -> (hue: CGFloat, saturation: CGFloat, lightness: CGFloat) {
        let components = AgnosticColor(self).sRGBComponents()
        return Self.rgbToHSL(red: components.red, green: components.green, blue: components.blue)
    }

    /// Calculates the color that provides the best contrast according to the specified
    /// contrast level, treating the level's minimum ratio as a floor to maximise against
    /// rather than a band to stay within.
    ///
    /// Candidates are drawn from pure white, pure black, and the full light *and* dark
    /// lightness ramp of `self` — searching only the light ramp would miss the correct
    /// candidates when picking a contrast color against a dark-scheme value.
    ///
    /// - Parameters:
    ///   - level: The contrast level to calculate.
    ///   - maxRatio: The optional maximum contrast ratio to consider. If nil, there's no
    ///   upper limit.
    /// - Returns: The `Color` that achieves the highest contrast while meeting `level`, or
    /// `nil` if no candidate does — silently returning white when nothing qualifies would be a
    /// confidently wrong answer to an accessibility question.
    internal func calculateBestContrast(
        for level: ContrastLevel,
        maxRatio: CGFloat? = nil
    ) -> Color? {
        let background = AgnosticColor(self)
        let candidateColors =
            [Color.white, Color.black]
            + ColorLevel.allCases.map { self.level($0, for: .light) }
            + ColorLevel.allCases.map { self.level($0, for: .dark) }

        let minRatio = CGFloat(level.minimumRatio)
        let upperLimit = maxRatio ?? .infinity

        var best: (color: Color, ratio: CGFloat)?
        for candidate in candidateColors {
            let ratio = background.contrastRatio(with: AgnosticColor(candidate))
            guard ratio >= minRatio, ratio <= upperLimit else { continue }
            if best == nil || ratio > best!.ratio {
                best = (candidate, ratio)
            }
        }
        return best?.color
    }
}

// MARK: - Private APIs

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

    /// Converts sRGB components to HSL.
    ///
    /// - Parameters:
    ///   - red: The red component, `0...1`.
    ///   - green: The green component, `0...1`.
    ///   - blue: The blue component, `0...1`.
    /// - Returns: The hue (degrees, `0..<360`), saturation, and lightness.
    private static func rgbToHSL(
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat
    ) -> (hue: CGFloat, saturation: CGFloat, lightness: CGFloat) {
        let maxComponent = max(red, green, blue)
        let minComponent = min(red, green, blue)
        let lightness = (maxComponent + minComponent) / 2
        let delta = maxComponent - minComponent

        guard delta > .ulpOfOne else { return (0, 0, lightness) }

        let saturation = delta / (1 - abs(2 * lightness - 1))

        var hue: CGFloat
        switch maxComponent {
            case red:
                hue = ((green - blue) / delta).truncatingRemainder(dividingBy: 6)
            case green:
                hue = (blue - red) / delta + 2
            default:
                hue = (red - green) / delta + 4
        }
        hue *= 60
        if hue < 0 { hue += 360 }

        return (hue, saturation, lightness)
    }
}
