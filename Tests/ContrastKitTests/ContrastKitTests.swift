//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import Testing

@testable import ContrastKit

#if canImport(UIKit)
import UIKit.UITraitCollection
#else
import AppKit.NSAppearance
#endif

// MARK: - Luminance & Contrast Ratio

@Suite("Luminance and contrast ratio")
struct LuminanceAndContrastRatioTests {

    @Test("Black luminance is zero")
    func blackLuminanceIsZero() {
        #expect(abs(Color.black.relativeLuminance - 0.0) < 0.0001)
    }

    @Test("White luminance is one")
    func whiteLuminanceIsOne() {
        #expect(abs(Color.white.relativeLuminance - 1.0) < 0.0001)
    }

    @Test("Black and white contrast reaches the maximum ratio of 21")
    func blackAndWhiteReachMaximumContrast() {
        #expect(abs(Color.black.contrastRatio(with: .white) - 21.0) < 0.0001)
    }

    @Test("Contrast ratio is symmetric")
    func contrastRatioIsSymmetric() {
        let a = Color(.sRGB, red: 0.3, green: 0.6, blue: 0.2, opacity: 1)
        let b = Color(.sRGB, red: 0.9, green: 0.1, blue: 0.4, opacity: 1)
        #expect(abs(a.contrastRatio(with: b) - b.contrastRatio(with: a)) < 0.0001)
    }

    @Test("meets(_:against:) matches the ratio comparison directly")
    func meetsMatchesRatioComparison() {
        #expect(Color.black.meets(.aaa, against: .white))
        #expect(Color.black.meets(.aa, against: .white))
        #expect(Color.black.meets(.aaLarge, against: .white))
    }
}

// MARK: - ContrastLevel

@Suite("ContrastLevel")
struct ContrastLevelTests {

    @Test("Minimum ratios match the WCAG 2.1 floors")
    func minimumRatiosMatchWCAG() {
        #expect(ContrastLevel.aaLarge.minimumRatio == 3.0)
        #expect(ContrastLevel.aa.minimumRatio == 4.5)
        #expect(ContrastLevel.aaa.minimumRatio == 7.0)
    }

    @Test("Levels are floors, not bands: a high ratio still meets a lower level")
    func levelsAreFloorsNotBands() {
        // Black vs white is a ratio of 21 — under the old band implementation this was
        // rejected by `.aa` (capped at 6.99) and `.aaLarge` (capped at 4.49) for being "too
        // readable". WCAG levels are minimums: meeting AAA also means meeting AA and AA Large.
        #expect(Color.black.meets(.aa, against: .white))
        #expect(Color.black.meets(.aaLarge, against: .white))
    }
}

// MARK: - Level Ramp (HSL correctness)

@Suite("Level ramp HSL correctness")
struct LevelRampTests {

    @Test("level(_:for:) uses true HSL saturation, not HSB saturation")
    func levelUsesTrueHSLSaturation() {
        // RGB (0.6, 0.2, 0.2): HSB saturation = (0.6-0.2)/0.6 = 0.667(repeating).
        // True HSL saturation = 0.4 / (1 - |2*0.4 - 1|) = 0.4 / 0.8 = 0.5.
        // Since `level(_:for:)` always overrides lightness with the level's own value, the
        // only way the HSB-as-HSL bug is externally observable is through saturation — so this
        // case (max component < 1, meaning HSB brightness != HSL-relevant extremes) is exactly
        // the one that distinguishes correct HSL from the old HSB misread.
        let base = Color(.sRGB, red: 0.6, green: 0.2, blue: 0.2, opacity: 1)
        let level500 = base.level(.level500, for: .light)
        let components = AgnosticColor(level500).sRGBComponents()

        // Correct HSL (hue 0, saturation 0.5, lightness 0.5) reconstructs to (0.75, 0.25, 0.25).
        #expect(abs(components.red - 0.75) < 0.001)
        #expect(abs(components.green - 0.25) < 0.001)
        #expect(abs(components.blue - 0.25) < 0.001)

        // The old HSB-as-HSL bug would have used saturation 0.667, reconstructing to roughly
        // (0.833, 0.167, 0.167) instead — assert we are not that.
        #expect(abs(components.red - 0.833) > 0.01)
    }

    @Test("level500 round-trips a color whose own lightness is already 0.5")
    func level500RoundTripsMidLightnessColor() {
        // Pure red is HSL(0°, 1.0, 0.5) — HSB and HSL saturation coincide here (both 1.0)
        // because the max component is already 1, so this case alone would not have caught
        // the HSB/HSL bug, but it does confirm level500 reproduces a color already at that
        // lightness.
        let red = Color(.sRGB, red: 1, green: 0, blue: 0, opacity: 1)
        let level500 = red.level(.level500, for: .light)
        let components = AgnosticColor(level500).sRGBComponents()

        #expect(abs(components.red - 1.0) < 0.001)
        #expect(abs(components.green - 0.0) < 0.001)
        #expect(abs(components.blue - 0.0) < 0.001)
    }

    @Test("Dark mode mirrors levels around 0.5")
    func darkModeMirrorsLevels() {
        let base = Color(.sRGB, red: 0.6, green: 0.2, blue: 0.2, opacity: 1)
        let light50 = AgnosticColor(base.level(.level50, for: .light)).sRGBComponents()
        let dark50 = AgnosticColor(base.level(.level50, for: .dark)).sRGBComponents()

        // level50 is lightness 0.95 in light mode and mirrors to level950 (0.05) in dark mode
        // — so the dark result should be much darker than the light one, not identical.
        let lightLuminance = 0.2126 * light50.red + 0.7152 * light50.green + 0.0722 * light50.blue
        let darkLuminance = 0.2126 * dark50.red + 0.7152 * dark50.green + 0.0722 * dark50.blue
        #expect(lightLuminance > darkLuminance)
    }
}

// MARK: - Best Contrast Selection

@Suite("Best contrast candidate selection")
struct BestContrastSelectionTests {

    @Test("aaContrastLevel picks black over white when black has the higher qualifying ratio")
    func aaContrastLevelPicksHighestQualifyingRatio() throws {
        // Against a pure white background, black gives a ratio of 21 — far above the AA floor
        // of 4.5. The old banded implementation capped `.aa` at 6.99 and would have rejected
        // black outright, falling through to a worse candidate (or the silent `.white`
        // fallback, which here would be white-on-white — completely unreadable).
        let best = try #require(Color.white.aaContrastLevel)
        let bestComponents = AgnosticColor(best).sRGBComponents()
        #expect(bestComponents.red < 0.01)
        #expect(bestComponents.green < 0.01)
        #expect(bestComponents.blue < 0.01)
    }

    @Test("No candidate meeting AAA returns nil instead of a silent, unvalidated white")
    func noQualifyingCandidateReturnsNil() {
        // Gray at sRGB component 0.45 has a relative luminance of ~0.1706. Every candidate
        // (pure white, pure black, and the full light/dark lightness ramp of this gray) tops
        // out at a contrast ratio of ~4.76 against it — nowhere near the AAA floor of 7.0.
        // The old implementation would have silently returned `.white` here without ever
        // checking whether white actually qualified.
        let midGray = Color(.sRGB, red: 0.45, green: 0.45, blue: 0.45, opacity: 1)
        #expect(midGray.aaaContrastLevel == nil)
        #expect(midGray.highestRatedContrastLevel == nil)

        // But AA (floor 4.5) is just barely reachable — the max achievable ratio here is ~4.76.
        #expect(midGray.aaContrastLevel != nil)
    }

    @Test("highestRatedContrastLevel has no upper bound on the ratio")
    func highestRatedContrastLevelHasNoUpperBound() throws {
        let best = try #require(Color.white.highestRatedContrastLevel)
        #expect(Color.white.contrastRatio(with: best) > 7.0)
    }
}

// MARK: - Alpha & Compositing

@Suite("Alpha handling")
struct AlphaHandlingTests {

    @Test("flattened(over:) composites using simple linear alpha blending")
    func flattenedComposites() {
        // 50% red over white: R = 1*0.5 + 1*0.5 = 1, G = 0*0.5 + 1*0.5 = 0.5, B = same as G.
        let translucentRed = Color(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.5)
        let flattened = translucentRed.flattened(over: .white)
        let components = AgnosticColor(flattened).sRGBComponents()

        #expect(abs(components.red - 1.0) < 0.001)
        #expect(abs(components.green - 0.5) < 0.001)
        #expect(abs(components.blue - 0.5) < 0.001)
        #expect(components.alpha == 1)
    }

    @Test("flattened(over:) changes the effective contrast ratio versus the unflattened color")
    func flattenedChangesContrastRatio() {
        let translucentBlack = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5)
        let overWhite = translucentBlack.flattened(over: .white)
        let overBlack = translucentBlack.flattened(over: .black)

        // 50% black over white is mid-gray; 50% black over black is still black.
        #expect(overWhite.contrastRatio(with: .white) < 21.0)
        #expect(abs(overBlack.contrastRatio(with: .black) - 1.0) < 0.01)
    }
}

// MARK: - P3 / Wide Gamut

@Suite("Wide gamut color space handling")
struct WideGamutTests {

    @Test("Display P3 colors are converted to sRGB before computing luminance")
    func p3ColorsAreConvertedBeforeLuminance() throws {
        // Empirically measured via CGColor's own P3->sRGB conversion: this color has an
        // oracle/naive luminance gap of ~0.034, comfortably clear of floating-point noise.
        let p3Color = AgnosticColor(displayP3Red: 0.9, green: 0.1, blue: 0.9, alpha: 1)

        // Independent oracle: ask CGColor to do the P3 -> sRGB conversion directly, then apply
        // the WCAG formula by hand, without calling into any of the package's own luminance
        // logic. This proves the package performs an equivalent conversion rather than reading
        // P3 components as if they were already sRGB.
        let sRGBSpace = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let converted = try #require(
            p3Color.cgColor.converted(to: sRGBSpace, intent: .defaultIntent, options: nil)
        )
        let oracleComponents = try #require(converted.components)

        func wcagComponent(_ c: CGFloat) -> CGFloat {
            c < 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        let oracleLuminance = Double(
            0.2126 * wcagComponent(oracleComponents[0])
            + 0.7152 * wcagComponent(oracleComponents[1])
            + 0.0722 * wcagComponent(oracleComponents[2])
        )

        // The naive/buggy reading: treat the P3 components as if they were already sRGB.
        let naiveLuminance = Double(
            0.2126 * wcagComponent(0.9) + 0.7152 * wcagComponent(0.1) + 0.0722 * wcagComponent(0.9)
        )

        let actualLuminance = p3Color.luminance()

        #expect(abs(Double(actualLuminance) - oracleLuminance) < 0.001)
        #expect(abs(Double(actualLuminance) - naiveLuminance) > 0.02)
    }
}

// MARK: - Trait-Aware Resolution

#if canImport(UIKit)

@Suite("Trait-aware resolution (UIKit)")
struct TraitAwareResolutionTests {

    /// A dynamic color that is white under any light appearance and black under any dark
    /// appearance — deliberately extreme so resolution differences are unambiguous.
    private var dynamicBlackOrWhite: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? .black : .white
        })
    }

    @Test("contrastRatio(with:compatibleWith:) resolves against the given traits, not the ambient ones")
    func contrastRatioResolvesAgainstExplicitTraits() {
        let dynamic = dynamicBlackOrWhite
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        // Against black (fixed), the dynamic color resolves to white in light mode (ratio 21)
        // and black in dark mode (ratio 1) — a real, appearance-dependent difference.
        let lightRatio = Color.black.contrastRatio(with: dynamic, compatibleWith: lightTraits)
        let darkRatio = Color.black.contrastRatio(with: dynamic, compatibleWith: darkTraits)

        #expect(abs(lightRatio - 21.0) < 0.01)
        #expect(abs(darkRatio - 1.0) < 0.01)
    }

    @Test("mostReadableForeground(from:meeting:compatibleWith:) picks the trait-correct candidate")
    func mostReadableForegroundResolvesAgainstExplicitTraits() throws {
        let dynamicBackground = dynamicBlackOrWhite
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        let lightForeground = try #require(
            dynamicBackground.mostReadableForeground(
                from: [.white, .black],
                meeting: .aaa,
                compatibleWith: lightTraits
            )
        )
        let darkForeground = try #require(
            dynamicBackground.mostReadableForeground(
                from: [.white, .black],
                meeting: .aaa,
                compatibleWith: darkTraits
            )
        )

        // Background is white in light mode, so the readable foreground must be black — and
        // vice versa in dark mode. A ratio of 1.0 means "identical color" (WCAG ratios are
        // never below 1.0, so this is the right way to assert "is essentially this color").
        #expect(abs(lightForeground.contrastRatio(with: .black) - 1.0) < 0.01)
        #expect(abs(darkForeground.contrastRatio(with: .white) - 1.0) < 0.01)
    }
}

#else

@Suite("Trait-aware resolution (AppKit)")
struct TraitAwareResolutionTests {

    /// A dynamic color that is white under a light appearance and black under a dark
    /// appearance — deliberately extreme so resolution differences are unambiguous.
    private var dynamicBlackOrWhite: Color {
        let nsColor = NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .black : .white
        }
        return Color(nsColor: nsColor)
    }

    @Test("contrastRatio(with:compatibleWith:) resolves against the given appearance, not the current one")
    func contrastRatioResolvesAgainstExplicitAppearance() throws {
        let dynamic = dynamicBlackOrWhite
        let lightAppearance = try #require(NSAppearance(named: .aqua))
        let darkAppearance = try #require(NSAppearance(named: .darkAqua))

        let lightRatio = Color.black.contrastRatio(with: dynamic, compatibleWith: lightAppearance)
        let darkRatio = Color.black.contrastRatio(with: dynamic, compatibleWith: darkAppearance)

        #expect(abs(lightRatio - 21.0) < 0.01)
        #expect(abs(darkRatio - 1.0) < 0.01)
    }

    @Test("mostReadableForeground(from:meeting:compatibleWith:) picks the appearance-correct candidate")
    func mostReadableForegroundResolvesAgainstExplicitAppearance() throws {
        let dynamicBackground = dynamicBlackOrWhite
        let lightAppearance = try #require(NSAppearance(named: .aqua))
        let darkAppearance = try #require(NSAppearance(named: .darkAqua))

        let lightForeground = try #require(
            dynamicBackground.mostReadableForeground(
                from: [.white, .black],
                meeting: .aaa,
                compatibleWith: lightAppearance
            )
        )
        let darkForeground = try #require(
            dynamicBackground.mostReadableForeground(
                from: [.white, .black],
                meeting: .aaa,
                compatibleWith: darkAppearance
            )
        )

        // A ratio of 1.0 means "identical color" (WCAG ratios are never below 1.0, so this is
        // the right way to assert "is essentially this color").
        #expect(abs(lightForeground.contrastRatio(with: .black) - 1.0) < 0.01)
        #expect(abs(darkForeground.contrastRatio(with: .white) - 1.0) < 0.01)
    }
}

#endif

// MARK: - Debug Safety Net

// Exit testing (`#expect(processExitsWith:)`) is only supported on macOS, Linux, FreeBSD,
// OpenBSD, and Windows runtime targets — not iOS, tvOS, watchOS, or visionOS. Gating this suite
// keeps the test target buildable when CI runs tests on those platforms.
#if os(macOS)

@Suite("Debug-only safety checks")
struct DebugSafetyTests {

    @Test("relativeLuminance asserts on a non-opaque color with no background to composite over")
    func luminanceAssertsOnUnflattenedAlpha() async {
        await #expect(processExitsWith: .failure) {
            let translucent = Color(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.5)
            _ = translucent.relativeLuminance
        }
    }
}

#endif
