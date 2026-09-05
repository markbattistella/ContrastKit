//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

#if canImport(UIKit)
import UIKit.UIColor
#else
import AppKit.NSColor
#endif

// MARK: - Internal API
extension AgnosticColor {
    /// Resolves this color's components into the sRGB color space, optionally compositing
    /// over a `background` color when this color is not fully opaque.
    ///
    /// Asset catalog colors default to Display P3 on modern platforms. Reading `cgColor`
    /// components directly — without this conversion — silently mixes P3-encoded values into
    /// formulas (like WCAG luminance) that are only valid in sRGB, producing confidently wrong
    /// numbers that grow with saturation.
    ///
    /// - Parameter background: The color to composite over when `self` has alpha < 1. Ignored
    ///   when `self` is already fully opaque.
    /// - Returns: The red, green, blue, and alpha components in sRGB space. Alpha is `1` if a
    ///   `background` was composited in.
    internal func sRGBComponents(
        compositingOver background: AgnosticColor? = nil
    ) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let raw: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

        #if os(macOS)
        let sRGBColor = usingColorSpace(.sRGB) ?? AgnosticColor.black
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        sRGBColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        raw = (r, g, b, a)
        #else
        if let sRGBSpace = CGColorSpace(name: CGColorSpace.sRGB),
            let converted = cgColor.converted(to: sRGBSpace, intent: .defaultIntent, options: nil),
            let components = converted.components
        {
            switch components.count {
                case 4:
                    raw = (components[0], components[1], components[2], components[3])
                case 2:
                    raw = (components[0], components[0], components[0], components[1])
                default:
                    raw = (0, 0, 0, 1)
            }
        }
        else {
            raw = (0, 0, 0, 1)
        }
        #endif

        guard let background, raw.alpha < 1 else { return raw }

        let backdrop = background.sRGBComponents()
        let alpha = raw.alpha
        return (
            red: raw.red * alpha + backdrop.red * (1 - alpha),
            green: raw.green * alpha + backdrop.green * (1 - alpha),
            blue: raw.blue * alpha + backdrop.blue * (1 - alpha),
            alpha: 1
        )
    }

    /// Computes the WCAG 2.1 relative luminance of the color, converting to sRGB first.
    ///
    /// - Parameter background: A color to composite over first when `self` is not fully
    ///   opaque. Required for a meaningful result on translucent colors — omitting it on a
    ///   translucent color silently ignores alpha (flagged via `assert` in debug builds).
    /// - Returns: A value in `0...1` representing the color's relative luminance.
    internal func luminance(compositingOver background: AgnosticColor? = nil) -> CGFloat {
        let components = sRGBComponents(compositingOver: background)

        assert(
            background != nil || components.alpha >= 0.999,
            "luminance() was called on a non-opaque color with no background to composite "
                + "over — the result ignores alpha and is not meaningful. Pass `compositingOver:` "
                + "or flatten the color first."
        )

        return calculateLuminance(red: components.red, green: components.green, blue: components.blue)
    }

    /// Computes the WCAG 2.1 contrast ratio between this color and `other`, in the range
    /// `1...21`. This is the single canonical implementation of the ratio formula — every
    /// other contrast calculation in the package routes through this method.
    internal func contrastRatio(with other: AgnosticColor) -> CGFloat {
        let luminance1 = luminance()
        let luminance2 = other.luminance()
        return (max(luminance1, luminance2) + 0.05) / (min(luminance1, luminance2) + 0.05)
    }

    /// Helper function to calculate luminance using the standard sRGB luminance formula.
    ///
    /// - Parameters:
    ///   - red: The red component of the color.
    ///   - green: The green component of the color.
    ///   - blue: The blue component of the color.
    /// - Returns: The calculated luminance as a CGFloat.
    private func calculateLuminance(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
        let rL = adjustedLuminance(component: red)
        let gL = adjustedLuminance(component: green)
        let bL = adjustedLuminance(component: blue)

        let redCoefficient: CGFloat = 0.2126
        let greenCoefficient: CGFloat = 0.7152
        let blueCoefficient: CGFloat = 0.0722

        return (redCoefficient * rL) + (greenCoefficient * gL) + (blueCoefficient * bL)
    }

    /// Adjusts the component value based on the sRGB luminance formula.
    ///
    /// - Parameter component: The color component value.
    /// - Returns: The adjusted luminance component.
    private func adjustedLuminance(component: CGFloat) -> CGFloat {
        let kLowRGBLuminanceMultiplier: CGFloat = 12.92
        let kHighRGBLuminanceMultiplier: CGFloat = 1.055
        let kHighRGBLuminanceAddend: CGFloat = 0.055
        let kLuminancePower: CGFloat = 2.4

        return component < 0.03928
            ? component / kLowRGBLuminanceMultiplier
            : pow((component + kHighRGBLuminanceAddend) / kHighRGBLuminanceMultiplier, kLuminancePower)
    }
}
