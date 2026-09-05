//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

#if DEBUG

import SwiftUI

/// An enumeration defining accessibility ratings based on contrast ratios.
internal enum AccessibilityRating: String {
    case fail = "Fail"
    case aaLarge = "AA Large"
    case aa = "AA"
    case aaa = "AAA"
}

extension Color {
    /// Returns a string describing the contrast information between this color and another.
    /// Includes the enforced contrast level.
    ///
    /// - Parameters:
    ///   - color: The other color to compare.
    ///   - level: The contrast level being enforced.
    /// - Returns: A string containing the contrast ratio, its corresponding accessibility
    /// rating, and the enforced level.
    internal func contrastInfo(with color: Color, for level: ContrastLevel? = nil) -> String {
        let ratio = self.contrastRatio(with: color)
        return String(
            format: "%.2f: %@\n(Enforced: %@)",
            ratio,
            AccessibilityRating.rating(for: ratio).rawValue,
            level?.rawValue ?? "None"
        )
    }
}

extension AccessibilityRating {
    /// Determines the accessibility rating based on the contrast ratio.
    ///
    /// - Parameter ratio: The contrast ratio.
    /// - Returns: The corresponding accessibility rating.
    fileprivate static func rating(for ratio: Double) -> AccessibilityRating {
        switch ratio {
            case ..<ContrastLevel.aaLarge.minimumRatio: .fail
            case ..<ContrastLevel.aa.minimumRatio: .aaLarge
            case ..<ContrastLevel.aaa.minimumRatio: .aa
            default: .aaa
        }
    }
}

/// A view component that displays a color shade along with its contrast information.
///
/// This view constructs a cell that visually represents a color shade (`shade`) and its
/// contrast color (`contrast`), along with informational text (`info`) that describes the
/// contrast details. It is designed to facilitate easy visualization of color contrasts in
/// different UI contexts, especially useful in settings where visual accessibility is tested.
///
/// - Parameters:
///   - level: The color level associated with the shade. Used to label the view.
///   - shade: The primary color of the view's background.
///   - contrast: The color used for text foreground to ensure it stands out against the `shade`.
///   - info: A string containing detailed information about the contrast ratio and/or other
///   relevant data.
internal struct ShadeCell: View {
    private let level: ColorLevel
    private let shade: Color
    private let contrast: Color
    private let info: String

    /// Initializes a new instance of `ShadeCell`.
    ///
    /// - Parameters:
    ///   - level: The color level for which this cell is being displayed.
    ///   - shade: The background color representing the specific color shade of the level.
    ///   - contrast: The color used for text that contrasts with the background shade.
    ///   - info: Textual information about the contrast properties or other relevant details.
    init(_ level: ColorLevel, shade: Color, contrast: Color, info: String) {
        self.level = level
        self.shade = shade
        self.contrast = contrast
        self.info = info
    }

    /// The content and layout body of the view.
    var body: some View {
        ZStack {
            shade
            VStack {
                Text(verbatim: "\(level)")
                Text(info)
            }
            .foregroundStyle(contrast)
            .font(.caption.bold())
            .multilineTextAlignment(.center)
        }
    }
}

#endif
