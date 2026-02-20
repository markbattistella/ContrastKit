//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Convenience APIs

@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
extension Color {

    /// Returns an environment-aware style at level 50 lightness.
    public var level50: ColorLevelStyle { self.level(.level50) }

    /// Returns an environment-aware style at level 100 lightness.
    public var level100: ColorLevelStyle { self.level(.level100) }

    /// Returns an environment-aware style at level 200 lightness.
    public var level200: ColorLevelStyle { self.level(.level200) }

    /// Returns an environment-aware style at level 300 lightness.
    public var level300: ColorLevelStyle { self.level(.level300) }

    /// Returns an environment-aware style at level 400 lightness.
    public var level400: ColorLevelStyle { self.level(.level400) }

    /// Returns an environment-aware style at level 500 lightness.
    public var level500: ColorLevelStyle { self.level(.level500) }

    /// Returns an environment-aware style at level 600 lightness.
    public var level600: ColorLevelStyle { self.level(.level600) }

    /// Returns an environment-aware style at level 700 lightness.
    public var level700: ColorLevelStyle { self.level(.level700) }

    /// Returns an environment-aware style at level 800 lightness.
    public var level800: ColorLevelStyle { self.level(.level800) }

    /// Returns an environment-aware style at level 900 lightness.
    public var level900: ColorLevelStyle { self.level(.level900) }

    /// Returns an environment-aware style at level 950 lightness.
    public var level950: ColorLevelStyle { self.level(.level950) }
}
