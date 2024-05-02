<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# ContrastKit

![Languages](https://img.shields.io/badge/Languages-Swift%20|%20SwiftUI%20|%20UIKit%20|%20AppKit-white?labelColor=orange&style=flat)

![Platforms](https://img.shields.io/badge/Platforms-iOS%2014+%20|%20iPadOS%2014+%20|%20macOS%2011+%20|%20tvOS%2014+-white?labelColor=gray&style=flat)

![Licence](https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat)

</div>

**ContrastKit** is a Swift library designed to facilitate colour contrast handling within iOS, iPadOS, macOS, and tvOS applications.

It provides developers with tools to automatically generate colour shades from any base colour and determine the most readable contrast colours according to established accessibility standards (AA Large, AA, and AAA).

This package is particularly useful for UI/UX designers and developers focusing on accessibility and readability in their applications.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [In-app Usage](#in-app-usage)
    - [SwiftUI](#swiftui)
    - [UIKit](#uikit)
    - [AppKit](#appkit)
- [Provided Levels](#provided-levels)
  - [Colour Range](#colour-range)
  - [Contrast](#contrast)
- [UITesting folder](#uitesting-folder)
  - [Debugging and Visualisation](#debugging-and-visualisation)
  - [Usage in Xcode](#usage-in-xcode)
  - [Integration with SwiftUI](#integration-with-swiftui)
  - [Why Use PreviewTesting?](#why-use-previewtesting)
- [Contributing](#contributing)
- [License](#license)

## Installation

The ContrastKit package uses Swift Package Manager (SPM) for easy addition. Follow these steps to add it to your project:

1. In Xcode, click `File -> Swift Packages -> Add Package Dependency`.
2. In the search bar, type `https://github.com/markbattistella/ContrastKit` and click `Next`.
3. Specify the version you want to use. You can select the exact version, use the latest one, or set a version range, and then click `Next`.
4. Finally, select the target in which you want to use `ContrastKit` and click `Finish`.

## Usage

Remember to import the `ContrastKit` module:

```swift
import ContrastKit
```

### Basic Usage

The default usage of the ContrastKit package is quite straightforward. Here's an example:

```swift
import ContrastKit

// Example usage in SwiftUI
let baseColor = Color.purple
let shadeColor = baseColor.level(.level100)
let contrastColor = shadeColor.highestRatedContrastLevel
let fixedContrastColor = shadeColor.aaLargeContrastLevel

// Example usage in UIKit
let uiColor = UIColor(contrastColor)  // Convert from SwiftUI Color to UIColor
```

The main call sites are designed for SwiftUI - but you can call `UIColor(color:)` too.

> [!NOTE]  
> Using `UIColor(color:)` has been available from `iOS 14.0+`, `Mac Catalyst 14.0+`, `tvOS 14.0+`, `watchOS 7.0+`, `visionOS 1.0+`, `Xcode 12.0+` so we're fairly okay, I hope...

### In-app usage

#### SwiftUI

```swift
import SwiftUI
import ContrastKit

struct ContentView: View {
  private let baseColor = Color.green
  private let contrastColor = baseColor.highestRatedContrastLevel
  var body: some View {
    Text("High Contrast Text")
      .foregroundColor(contrastColor)
      .background(baseColor)
  }
}
```

Or if you want to select a specific shade in the UI (suppose you've built a consistent theme):

```swift
import SwiftUI
import ContrastKit

struct ContentView: View {
  private let baseColor = Color.green
  var body: some View {
    Text("Set themed text")
      .foregroundColor(baseColor)
      .background(baseColor.level50)
  }
}
```

#### UIKit

```swift
import UIKit
import ContrastKit

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let baseUIColor = UIColor.systemBlue
    let contrastKitColor = Color(baseUIColor)
    let highContrastUIColor = UIColor(contrastKitColor.highestRatedContrastLevel)

    let label = UILabel()
    label.text = "High Contrast Label"
    label.textColor = highContrastUIColor
    label.backgroundColor = baseUIColor
    label.frame = CGRect(x: 20, y: 100, width: 300, height: 50)
    label.textAlignment = .center

    self.view.addSubview(label)
  }
}
```

#### AppKit

```swift
import AppKit
import ContrastKit

class ViewController: NSViewController {
  override func loadView() {
    self.view = NSView()
    let baseNSColor = NSColor.systemRed
    let contrastKitColor = Color(baseNSColor)
    let highContrastNSColor = NSColor(contrastKitColor.highestRatedContrastLevel)

    let textField = NSTextField(labelWithString: "High Contrast Text")
    textField.textColor = highContrastNSColor
    textField.backgroundColor = baseNSColor
    textField.frame = CGRect(x: 20, y: 20, width: 300, height: 50)
    textField.isBezeled = false
    textField.drawsBackground = true

    self.view.addSubview(textField)
  }
}
```

## Provided Levels

ContrastKit provides two core enums to assist in designing UIs with appropriate colour contrast: `ColorLevel` and `ContrastLevel`. These enums help developers standardise the visual accessibility of their applications.

### Colour Range

The `ColorLevel` enum defines different levels of lightness for colours, which can be used to generate various shades from a single base colour. These shades range from very light (near white) to very dark (near black), suitable for different UI elements like backgrounds, text, and interactive elements.

| Level    | Lightness | Description                                                         |
| -------- | --------- | ------------------------------------------------------------------- |
| level50  | 0.95      | Very light shade, almost white.                                     |
| level100 | 0.90      | Very light shade.                                                   |
| level200 | 0.80      | Lighter shade, for subtle backgrounds.                              |
| level300 | 0.70      | Light shade, good for hover states or secondary buttons.            |
| level400 | 0.60      | Medium light shade.                                                 |
| level500 | 0.50      | Neutral base shade, often used for the primary variant of a colour. |
| level600 | 0.40      | Medium dark shade.                                                  |
| level700 | 0.30      | Darker shade, suitable for text.                                    |
| level800 | 0.20      | Very dark shade, often used for text or active elements.            |
| level900 | 0.10      | Very dark, closer to black.                                         |
| level950 | 0.05      | Extremely dark, almost black.                                       |

### Contrast

The `ContrastLevel` enum specifies minimum and maximum contrast ratios for three accessibility standards: AA Large, AA, and AAA. These levels are based on the WCAG guidelines to ensure that text and interactive elements are readable and accessible.

| Level    | Minimum Ratio | Maximum Ratio | Description                                     |
| -------- | ------------- | ------------- | ----------------------------------------------- |
| AA Large | 3.0           | 4.49          | Suitable for large text, offering basic readability. |
| AA       | 4.5           | 6.99          | Standard level for normal text size, providing clear readability. |
| AAA      | 7.0           | ∞             | Highest contrast level, recommended for the best readability across all contexts. |

## UITesting folder

The `PreviewTesting` file is a vital part of the ContrastKit package, designed exclusively for debugging and visual inspection purposes during the development process.

It allows developers to quickly view and evaluate the contrast levels and colour shades generated by the library directly within the SwiftUI Preview environment.

This file contains sample views and configurations that demonstrate the practical application of ContrastKit.

### Debugging and Visualisation

The file includes an `Example+SwiftUI` file that utilises ContrastKit functionalities to display a series of colours with varying levels of contrast. This visual representation helps in understanding how different colours and their respective contrast levels appear in a UI context.

There are two previews available - `StandardShadeView` and `EnvironmentShadeView`.

The first is an example, where the shades of colours and their contrast colours are fixed regardless of the device colour scheme.

In the `EnvironmentShadeView` example, you can see how to pass in the `@Environment(\.colorScheme)` to the `level(_:scheme:)` function and it will update the colours automatically for you.

### Usage in Xcode

To use this file effectively:

1. Open your Xcode project containing the ContrastKit.
1. Navigate to the PreviewTesting file.
1. Ensure your environment is set to Debug mode to activate the #if DEBUG condition.
1. Open the SwiftUI Preview pane to see the results.

> [!CAUTION]
> This file is intended for development use only and should not be included in the production build of the application.

It provides a straightforward and effective way to visually inspect the accessibility features provided by ContrastKit, ensuring that the colour contrasts meet the required standards before the application is deployed.

### Integration with SwiftUI

The `PreviewTesting` file demonstrates the integration of ContrastKit with SwiftUI, showing how easily developers can implement and test colour contrasts in their UI designs.

By modifying the `baseColor` or the `ColorLevel`, developers can experiment with different combinations to find the optimal settings for their specific needs.

### Why Use PreviewTesting?

- **Immediate Feedback:** Allows developers to see how changes in colour levels affect accessibility and readability in real-time.
- **Accessibility Testing:** Helps in ensuring that the UI meets accessibility standards, particularly when creating inclusive applications.
- **Ease of Use:** Simplifies the process of testing multiple colour schemes without needing to deploy the app or navigate through different screens.

The `PreviewTesting` file is a crucial tool for developers who are serious about integrating effective contrast handling in their applications, making ContrastKit a practical choice for enhancing UI accessibility.

## Contributing

Contributions are highly encouraged, as they help make ContrastKit even more useful to the developer community. Feel free to fork the project, submit pull requests, or send suggestions via GitHub issues.

## License

ContrastKit is available under the MIT license, allowing for widespread use and modification in both personal and commercial projects. See the LICENSE file included in the repository for full details.
