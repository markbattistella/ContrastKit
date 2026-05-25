//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Testing

@testable import ContrastKit

@Suite("ContrastKit color contrast")
struct ContrastKitTests {

  /// Tests the luminance calculation for the black color.
  @Test("Black luminance is zero")
  func blackLuminanceCalculation() {
    let black = AgnosticColor.black
    #expect(black.luminance() == 0.0)
  }

  /// Tests the luminance calculation for the white color.
  @Test("White luminance is one")
  func whiteLuminanceCalculation() {
    let white = AgnosticColor.white
    #expect(white.luminance() == 1.0)
  }

  /// Tests the contrast ratio calculation between black and white colors.
  @Test("Black and white contrast reaches AAA")
  func contrastRatio() {
    let black = AgnosticColor.black
    let white = AgnosticColor.white
    let result = black.contrastRatio(with: white)
    #expect(result.ratio == 21.0)
    #expect(result.rating == "AAA")
  }
}
