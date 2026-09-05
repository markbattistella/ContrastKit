//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

#if canImport(UIKit)
import UIKit.UITraitCollection

// MARK: - Trait-Aware Resolution (UIKit)

extension Color {

    /// The WCAG 2.1 relative luminance of this colour when resolved against an explicit
    /// `UITraitCollection`, rather than whatever traits happen to be ambient.
    ///
    /// A dynamic colour (an asset catalog colour, `Color(uiColor:)` wrapping a dynamic
    /// `UIColor`, etc.) only has one concrete value once resolved against a trait collection.
    /// Reading it without one resolves against `UITraitCollection.current`, which is
    /// unpredictable in tests and wrong outside the screen the call happens to run on.
    ///
    /// - Parameter traitCollection: The traits to resolve `self` against.
    /// - Returns: The relative luminance, `0...1`.
    public func relativeLuminance(compatibleWith traitCollection: UITraitCollection) -> Double {
        Double(UIColor(self).resolvedColor(with: traitCollection).luminance())
    }

    /// The WCAG 2.1 contrast ratio between this colour and `other`, resolving both against an
    /// explicit `UITraitCollection`.
    ///
    /// Accessibility contrast (Increase Contrast) is its own trait, not just light/dark — use
    /// it alongside `userInterfaceStyle` when a palette needs to be proven legal across every
    /// appearance an app actually ships, not only light and dark:
    ///
    /// ```swift
    /// let highContrastDark = UITraitCollection(traitsFrom: [
    ///     UITraitCollection(userInterfaceStyle: .dark),
    ///     UITraitCollection(accessibilityContrast: .high)
    /// ])
    /// let ratio = accent.contrastRatio(with: onAccent, compatibleWith: highContrastDark)
    /// #expect(ratio >= ContrastLevel.aaa.minimumRatio)
    /// ```
    ///
    /// - Parameters:
    ///   - other: The colour to compare against.
    ///   - traitCollection: The traits to resolve both colours against.
    /// - Returns: The contrast ratio, `1...21`.
    public func contrastRatio(
        with other: Color,
        compatibleWith traitCollection: UITraitCollection
    ) -> Double {
        let resolvedSelf = UIColor(self).resolvedColor(with: traitCollection)
        let resolvedOther = UIColor(other).resolvedColor(with: traitCollection)
        return Double(resolvedSelf.contrastRatio(with: resolvedOther))
    }

    /// Whether this colour and `other` meet or exceed `level`'s minimum contrast ratio when
    /// resolved against an explicit `UITraitCollection`.
    ///
    /// - Parameters:
    ///   - level: The WCAG level to check against.
    ///   - other: The colour to compare against.
    ///   - traitCollection: The traits to resolve both colours against.
    /// - Returns: `true` if the pair meets or exceeds `level.minimumRatio` under those traits.
    public func meets(
        _ level: ContrastLevel,
        against other: Color,
        compatibleWith traitCollection: UITraitCollection
    ) -> Bool {
        contrastRatio(with: other, compatibleWith: traitCollection) >= level.minimumRatio
    }

    /// Picks whichever colour in `candidates` achieves the highest contrast against `self`
    /// while still meeting `level`, resolving every colour against an explicit
    /// `UITraitCollection`.
    ///
    /// This is how a colour like `theme-on-accent` gets derived once per accent, per
    /// appearance, instead of hand-tuned across every combination of light/dark and increased
    /// contrast a theme needs to support.
    ///
    /// - Parameters:
    ///   - candidates: The colours to choose from.
    ///   - level: The WCAG level every returned colour must meet.
    ///   - traitCollection: The traits to resolve every colour against.
    /// - Returns: The best-contrasting candidate that meets `level` under those traits, or
    /// `nil` if none do.
    public func mostReadableForeground(
        from candidates: [Color],
        meeting level: ContrastLevel,
        compatibleWith traitCollection: UITraitCollection
    ) -> Color? {
        let resolvedSelf = UIColor(self).resolvedColor(with: traitCollection)
        let minRatio = CGFloat(level.minimumRatio)

        var best: (color: Color, ratio: CGFloat)?
        for candidate in candidates {
            let resolvedCandidate = UIColor(candidate).resolvedColor(with: traitCollection)
            let ratio = resolvedSelf.contrastRatio(with: resolvedCandidate)
            guard ratio >= minRatio else { continue }
            if best == nil || ratio > best!.ratio {
                best = (candidate, ratio)
            }
        }
        return best?.color
    }
}

#else
import AppKit.NSAppearance

// MARK: - Trait-Aware Resolution (AppKit)

extension Color {

    /// The WCAG 2.1 relative luminance of this colour when resolved against an explicit
    /// `NSAppearance`, rather than whatever appearance is currently active.
    ///
    /// - Parameter appearance: The appearance to resolve `self` against.
    /// - Returns: The relative luminance, `0...1`.
    public func relativeLuminance(compatibleWith appearance: NSAppearance) -> Double {
        var luminance: CGFloat = 0
        appearance.performAsCurrentDrawingAppearance {
            luminance = AgnosticColor(self).luminance()
        }
        return Double(luminance)
    }

    /// The WCAG 2.1 contrast ratio between this colour and `other`, resolving both against an
    /// explicit `NSAppearance`.
    ///
    /// ```swift
    /// let highContrastDark = NSAppearance(named: .accessibilityHighContrastDarkAqua)!
    /// let ratio = accent.contrastRatio(with: onAccent, compatibleWith: highContrastDark)
    /// #expect(ratio >= ContrastLevel.aaa.minimumRatio)
    /// ```
    ///
    /// - Parameters:
    ///   - other: The colour to compare against.
    ///   - appearance: The appearance to resolve both colours against.
    /// - Returns: The contrast ratio, `1...21`.
    public func contrastRatio(with other: Color, compatibleWith appearance: NSAppearance) -> Double {
        var ratio: CGFloat = 0
        appearance.performAsCurrentDrawingAppearance {
            ratio = AgnosticColor(self).contrastRatio(with: AgnosticColor(other))
        }
        return Double(ratio)
    }

    /// Whether this colour and `other` meet or exceed `level`'s minimum contrast ratio when
    /// resolved against an explicit `NSAppearance`.
    ///
    /// - Parameters:
    ///   - level: The WCAG level to check against.
    ///   - other: The colour to compare against.
    ///   - appearance: The appearance to resolve both colours against.
    /// - Returns: `true` if the pair meets or exceeds `level.minimumRatio` under that appearance.
    public func meets(
        _ level: ContrastLevel,
        against other: Color,
        compatibleWith appearance: NSAppearance
    ) -> Bool {
        contrastRatio(with: other, compatibleWith: appearance) >= level.minimumRatio
    }

    /// Picks whichever colour in `candidates` achieves the highest contrast against `self`
    /// while still meeting `level`, resolving every colour against an explicit `NSAppearance`.
    ///
    /// - Parameters:
    ///   - candidates: The colours to choose from.
    ///   - level: The WCAG level every returned colour must meet.
    ///   - appearance: The appearance to resolve every colour against.
    /// - Returns: The best-contrasting candidate that meets `level` under that appearance, or
    /// `nil` if none do.
    public func mostReadableForeground(
        from candidates: [Color],
        meeting level: ContrastLevel,
        compatibleWith appearance: NSAppearance
    ) -> Color? {
        let minRatio = CGFloat(level.minimumRatio)
        var best: (color: Color, ratio: CGFloat)?

        appearance.performAsCurrentDrawingAppearance {
            let resolvedSelf = AgnosticColor(self)
            for candidate in candidates {
                let ratio = resolvedSelf.contrastRatio(with: AgnosticColor(candidate))
                guard ratio >= minRatio else { continue }
                if best == nil || ratio > best!.ratio {
                    best = (candidate, ratio)
                }
            }
        }
        return best?.color
    }
}

#endif
