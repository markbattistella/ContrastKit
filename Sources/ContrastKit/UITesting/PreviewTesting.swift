//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

#if DEBUG

import SwiftUI

/// An enumeration defining accessibility ratings based on contrast ratios.
enum AccessibilityRating: String {
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
        let selfUIColor = AgnosticColor(self)
        let otherUIColor = AgnosticColor(color)
        let contrastDetails = selfUIColor.contrastRatio(with: otherUIColor)
        return String(format: "%.2f: %@\n(Enforced: %@)", contrastDetails.ratio, contrastDetails.rating, level?.rawValue ?? "None")
    }
}

extension AgnosticColor {

    /// Calculates the contrast ratio between this color and another specified color and determines
    /// the accessibility rating based on that ratio.
    ///
    /// - Parameter otherColor: The other color to compare with.
    /// - Returns: A tuple containing the contrast ratio and the accessibility rating as a string.
    public func contrastRatio(with otherColor: AgnosticColor) -> (ratio: CGFloat, rating: String) {
        let luminance1 = self.luminance()
        let luminance2 = otherColor.luminance()
        let ratio = (max(luminance1, luminance2) + 0.05) / (min(luminance1, luminance2) + 0.05)

        return (ratio, rating(for: ratio))
    }

    /// Determines the accessibility rating based on the contrast ratio.
    ///
    /// - Parameter ratio: The contrast ratio.
    /// - Returns: The corresponding accessibility rating as a string.
    private func rating(for ratio: CGFloat) -> String {
        switch ratio {
            case ..<3:
                return AccessibilityRating.fail.rawValue
            case ..<4.5:
                return AccessibilityRating.aaLarge.rawValue
            case ..<7:
                return AccessibilityRating.aa.rawValue
            default:
                return AccessibilityRating.aaa.rawValue
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
                Text("\(level)")
                Text(info)
            }
            .foregroundColor(contrast)
            .font(.caption.bold())
            .multilineTextAlignment(.center)
        }
    }
}

#endif
