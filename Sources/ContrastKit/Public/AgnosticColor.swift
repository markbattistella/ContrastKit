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

@available(iOS 14.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
public typealias AgnosticColor = UIColor

#else

import AppKit.NSColor

@available(macOS 11.0, *)
public typealias AgnosticColor = NSColor

#endif
