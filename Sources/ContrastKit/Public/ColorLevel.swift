//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// Enum defining specific lightness levels for colors, useful for generating color themes or
/// ensuring accessible contrast.
@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
public enum ColorLevel: CaseIterable {

    case level50, level100, level200, level300, level400, level500,
         level600, level700, level800, level900, level950

    /// Provides the lightness value associated with each color level.
    var lightness: CGFloat {
        switch self {

            // Very light shade, almost white.
            case .level50:  return 0.95

            // Very light shade.
            case .level100: return 0.90

            // Lighter shade, for subtle backgrounds.
            case .level200: return 0.80

            // Light shade, good for hover states or secondary buttons.
            case .level300: return 0.70

            // Medium light shade.
            case .level400: return 0.60

            // Neutral base shade, often used for the primary variant of a color.
            case .level500: return 0.50

            // Medium dark shade.
            case .level600: return 0.40

            // Darker shade, suitable for text.
            case .level700: return 0.30

            // Very dark shade, often used for text or active elements.
            case .level800: return 0.20

            // Very dark, closer to black.
            case .level900: return 0.10

            // Extremely dark, almost black.
            case .level950: return 0.05
        }
    }

    /// Returns the corresponding level for dark mode.
    var correspondingDarkModeLevel: ColorLevel {
        switch self {
            case .level50:  return .level950
            case .level100: return .level900
            case .level200: return .level800
            case .level300: return .level700
            case .level400: return .level600
            case .level500: return .level500
            case .level600: return .level400
            case .level700: return .level300
            case .level800: return .level200
            case .level900: return .level100
            case .level950: return .level50
        }
    }
}
