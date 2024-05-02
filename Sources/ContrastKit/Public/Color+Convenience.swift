//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Concenience APIs

extension Color {
    
    /// Returns a color at level 50 brightness.
    public var level50: Color { self.level(.level50) }
    
    /// Returns a color at level 100 brightness.
    public var level100: Color { self.level(.level100) }
    
    /// Returns a color at level 200 brightness.
    public var level200: Color { self.level(.level200) }
    
    /// Returns a color at level 300 brightness.
    public var level300: Color { self.level(.level300) }
    
    /// Returns a color at level 400 brightness.
    public var level400: Color { self.level(.level400) }
    
    /// Returns a color at level 500 brightness.
    public var level500: Color { self.level(.level500) }
    
    /// Returns a color at level 600 brightness.
    public var level600: Color { self.level(.level600) }
    
    /// Returns a color at level 700 brightness.
    public var level700: Color { self.level(.level700) }
    
    /// Returns a color at level 800 brightness.
    public var level800: Color { self.level(.level800) }
    
    /// Returns a color at level 900 brightness.
    public var level900: Color { self.level(.level900) }
    
    /// Returns a color at level 950 brightness.
    public var level950: Color { self.level(.level950) }
}
