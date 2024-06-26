//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

#if DEBUG && canImport(SwiftUI)

import SwiftUI

// MARK: - UI Preview

@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
internal struct StandardShadeView: View {

    private let baseColor = Color.pink
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                ForEach(ColorLevel.allCases, id: \.self) { level in
                    let shadeColor = baseColor.level(level)
                    let contrastColor = shadeColor.highestRatedContrastLevel
                    let contrastInfo = shadeColor.contrastInfo(with: contrastColor)
                    ShadeCell(level, shade: shadeColor, contrast: contrastColor, info: contrastInfo)
                }
            }
            VStack(spacing: 0) {
                ForEach(ColorLevel.allCases, id: \.self) { level in
                    let shadeColor = baseColor.level(level)
                    let contrastColor = shadeColor.aaLargeContrastLevel
                    let contrastInfo = shadeColor.contrastInfo(with: contrastColor, for: .aaLarge)
                    ShadeCell(level, shade: shadeColor, contrast: contrastColor, info: contrastInfo)
                }
            }
        }
    }
}

@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
internal struct EnvironmentShadeView: View {

    @Environment(\.colorScheme)
    private var colorScheme

    private let baseColor = Color.pink

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                ForEach(ColorLevel.allCases, id: \.self) { level in
                    let shadeColor = baseColor.level(level, scheme: colorScheme)
                    let contrastColor = shadeColor.highestRatedContrastLevel
                    let contrastInfo = shadeColor.contrastInfo(with: contrastColor)
                    ShadeCell(level, shade: shadeColor, contrast: contrastColor, info: contrastInfo)
                }
            }
            VStack(spacing: 0) {
                ForEach(ColorLevel.allCases, id: \.self) { level in
                    let shadeColor = baseColor.level(level, scheme: colorScheme)
                    let contrastColor = shadeColor.aaLargeContrastLevel
                    let contrastInfo = shadeColor.contrastInfo(with: contrastColor, for: .aaLarge)
                    ShadeCell(level, shade: shadeColor, contrast: contrastColor, info: contrastInfo)
                }
            }
            VStack {
                baseColor.level(.level100, scheme: colorScheme)
                baseColor.level(.level900, scheme: colorScheme)

                baseColor.level(.level100, scheme: colorScheme).level900
                baseColor.level(.level900, scheme: colorScheme).level100
            }
        }
    }
}

#Preview("ColorScheme: Fixed") { StandardShadeView() }
#Preview("ColorScheme: Environment") { EnvironmentShadeView() }

#endif
