//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

// Provides a platform-independent typealias for color representation.
// This file ensures that the same code can be used seamlessly across
// UIKit (iOS) and AppKit (macOS).

#if canImport(UIKit)

import UIKit.UIColor
public typealias AgnosticColor = UIColor

#else

import AppKit.NSColor
public typealias AgnosticColor = NSColor

#endif
