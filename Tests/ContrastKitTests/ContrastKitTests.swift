//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import XCTest
@testable import ContrastKit

final class ContrastKitTests: XCTestCase {

    /// Tests the luminance calculation for the black color.
    func testBlackLuminanceCalculation() {
        let black = AgnosticColor.black
        XCTAssertEqual(black.luminance(), 0.0, "Luminance of black should be 0.0")
    }

    /// Tests the luminance calculation for the white color.
    func testWhiteLuminanceCalculation() {
        let white = AgnosticColor.white
        XCTAssertEqual(white.luminance(), 1.0, "Luminance of white should be 1.0")
    }

    /// Tests the contrast ratio calculation between black and white colors.
    func testContrastRatio() {
        let black = AgnosticColor.black
        let white = AgnosticColor.white
        let result = black.contrastRatio(with: white)
        XCTAssertEqual(result.ratio, 21.0, "Contrast ratio between black and white should be 21.0")
        XCTAssertEqual(result.rating, "AAA", "Contrast rating should be AAA")
    }
}
