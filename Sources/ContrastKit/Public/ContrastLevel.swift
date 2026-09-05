//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// Defines the contrast levels used to ensure accessibility in user interfaces.
///
/// This enum provides named contrast levels corresponding to the WCAG accessibility guidelines:
/// - AA Large: Minimum contrast for large text.
/// - AA: Standard minimum contrast for normal text.
/// - AAA: Enhanced contrast for improved readability.
public enum ContrastLevel: String, Sendable {

    /// Contrast level for large text, typically for visual accessibility.
    case aaLarge = "AA Large"

    /// Standard contrast level for normal text size, ensuring clear readability.
    case aa = "AA"

    /// Highest contrast level, recommended for the best readability in all contexts.
    case aaa = "AAA"

    /// The minimum WCAG 2.1 contrast ratio required to meet this level.
    ///
    /// WCAG levels are floors, not bands: a ratio of `8.0` still meets `.aa` — it simply also
    /// meets the stricter `.aaa`. Use this value to check `ratio >= level.minimumRatio`, never
    /// to reject a ratio for being "too readable".
    public var minimumRatio: Double {
        switch self {
            case .aaLarge: 3.0
            case .aa: 4.5
            case .aaa: 7.0
        }
    }
}
