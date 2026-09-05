//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Level Ramp

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
            hue: components.hue,
            saturation: components.saturation,
            lightness: adjustedLevel.lightness
        )
    }
}

// MARK: - Contrast Measurement

extension Color {

    /// The WCAG 2.1 relative luminance of this colour, in the range `0...1`.
    ///
    /// Converts to sRGB before computing luminance, so the result is correct for Display P3
    /// (and other wide-gamut) asset catalog colours, not just colours already in sRGB.
    ///
    /// - Precondition: `self` should be fully opaque. A translucent colour's true luminance
    /// depends on what's behind it — use ``flattened(over:)`` first, or this will assert in
    /// debug builds and silently ignore alpha in release builds.
    public var relativeLuminance: Double {
        Double(AgnosticColor(self).luminance())
    }

    /// The WCAG 2.1 contrast ratio between this colour and `other`, in the range `1...21`.
    ///
    /// This is the calculation every accessibility test needs and the one thing the package
    /// previously had no way to ask for directly — every other API only ever picked a colour.
    ///
    /// ```swift
    /// #expect(accent.contrastRatio(with: onAccent) >= ContrastLevel.aaa.minimumRatio)
    /// ```
    ///
    /// - Precondition: both colours should be fully opaque — see ``relativeLuminance``.
    /// - Parameter other: The colour to compare against.
    /// - Returns: The contrast ratio, `1...21`.
    public func contrastRatio(with other: Color) -> Double {
        Double(AgnosticColor(self).contrastRatio(with: AgnosticColor(other)))
    }

    /// Whether this colour and `other` meet or exceed `level`'s minimum contrast ratio.
    ///
    /// - Parameters:
    ///   - level: The WCAG level to check against.
    ///   - other: The colour to compare against.
    /// - Returns: `true` if the pair meets or exceeds `level.minimumRatio`.
    public func meets(_ level: ContrastLevel, against other: Color) -> Bool {
        contrastRatio(with: other) >= level.minimumRatio
    }

    /// Returns this colour alpha-composited over an opaque `backdrop`, discarding transparency.
    ///
    /// WCAG contrast is only defined for opaque colours — a translucent foreground's effective
    /// colour depends entirely on what's behind it. Flatten explicitly before measuring
    /// contrast on any colour that isn't already fully opaque.
    ///
    /// - Parameter backdrop: The opaque colour to composite over.
    /// - Returns: An opaque `Color` representing `self` as it would actually appear over
    /// `backdrop`.
    public func flattened(over backdrop: Color) -> Color {
        let components = AgnosticColor(self).sRGBComponents(compositingOver: AgnosticColor(backdrop))
        return Color(
            .sRGB,
            red: Double(components.red),
            green: Double(components.green),
            blue: Double(components.blue),
            opacity: 1
        )
    }
}

// MARK: - Foreground Selection

extension Color {

    /// Picks whichever colour in `candidates` achieves the highest contrast against `self`
    /// while still meeting `level`, treating `level` as a floor to maximise beyond rather than
    /// a band to stay inside.
    ///
    /// This is how a derived colour like `theme-on-accent` gets built from a small candidate
    /// set (typically `[.white, .black]`) instead of hand-tuned per accent colour.
    ///
    /// ```swift
    /// let onAccent = accent.mostReadableForeground(from: [.white, .black], meeting: .aaa)
    /// ```
    ///
    /// - Parameters:
    ///   - candidates: The colours to choose from.
    ///   - level: The WCAG level every returned colour must meet.
    /// - Returns: The best-contrasting candidate that meets `level`, or `nil` if none do.
    public func mostReadableForeground(
        from candidates: [Color],
        meeting level: ContrastLevel
    ) -> Color? {
        let background = AgnosticColor(self)
        let minRatio = CGFloat(level.minimumRatio)

        var best: (color: Color, ratio: CGFloat)?
        for candidate in candidates {
            let ratio = background.contrastRatio(with: AgnosticColor(candidate))
            guard ratio >= minRatio else { continue }
            if best == nil || ratio > best!.ratio {
                best = (candidate, ratio)
            }
        }
        return best?.color
    }

    /// Returns the colour that achieves the highest possible contrast, drawn from pure
    /// white/black and this colour's own light and dark lightness ramp.
    ///
    /// This property has no upper limit on the contrast ratio, aiming to enhance readability
    /// and accessibility. Returns `nil` if no candidate meets AAA.
    public var highestRatedContrastLevel: Color? {
        calculateBestContrast(for: .aaa, maxRatio: .infinity)
    }

    /// The candidate (from pure white/black and this colour's lightness ramp) that best meets
    /// the AAA contrast level, or `nil` if none do.
    public var aaaContrastLevel: Color? {
        calculateBestContrast(for: .aaa)
    }

    /// The candidate (from pure white/black and this colour's lightness ramp) that best meets
    /// the AA contrast level, or `nil` if none do.
    public var aaContrastLevel: Color? {
        calculateBestContrast(for: .aa)
    }

    /// The candidate (from pure white/black and this colour's lightness ramp) that best meets
    /// the AA Large contrast level, or `nil` if none do.
    public var aaLargeContrastLevel: Color? {
        calculateBestContrast(for: .aaLarge)
    }
}
