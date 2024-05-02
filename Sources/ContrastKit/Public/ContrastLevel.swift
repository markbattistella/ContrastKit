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
@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
public enum ContrastLevel: String {

    /// Contrast level for large text, typically for visual accessibility.
    case aaLarge = "AA Large"

    /// Standard contrast level for normal text size, ensuring clear readability.
    case aa = "AA"

    /// Highest contrast level, recommended for the best readability in all contexts.
    case aaa = "AAA"

    /// Provides the minimum and maximum contrast ratios for each contrast level.
    ///
    /// These values define the acceptable range of contrast ratios to meet or exceed specific
    /// accessibility requirements:
    /// - For `aaLarge`, the range is suitable for large text.
    /// - For `aa`, the range is set for normal text.
    /// - For `aaa`, the range encompasses the highest contrast ratio, suitable for all types 
    /// of text to ensure optimal readability.
    var ratio: (min: CGFloat, max: CGFloat) {
        switch self {
            case .aaLarge:
                return (3.0, 4.49)
            case .aa:
                return (4.5, 6.99)
            case .aaa:
                return (7.0, CGFloat.infinity)
        }
    }
}
