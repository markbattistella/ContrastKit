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

    /// Computes the perceived luminance of the color using the sRGB formula.
    /// This method handles different color spaces including RGB and grayscale.
    ///
    /// - Returns: A CGFloat representing the luminance of the color.
    internal func luminance() -> CGFloat {
        guard let components = cgColor.components else { return 0 }
        let numberOfComponents = components.count
        let r: CGFloat, g: CGFloat, b: CGFloat

        switch numberOfComponents {
            case 4: // RGBA
                r = components[0]
                g = components[1]
                b = components[2]
            case 2, 1: // Grayscale
                r = components[0]
                g = components[0]
                b = components[0]
            default: // Unexpected color space
                r = 0
                g = 0
                b = 0
        }

        return calculateLuminance(red: r, green: g, blue: b)
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

        return component < 0.03928 ?
        component / kLowRGBLuminanceMultiplier :
        pow((component + kHighRGBLuminanceAddend) / kHighRGBLuminanceMultiplier, kLuminancePower)
    }
}
