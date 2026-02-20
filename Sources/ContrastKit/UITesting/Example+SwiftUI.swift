//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

#if DEBUG && canImport(SwiftUI)

import SwiftUI

// MARK: - UI Preview

/// Shows fixed light-mode shades with contrast info.
internal struct StandardShadeView: View {

    private let baseColor = Color.pink

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                ForEach(ColorLevel.allCases, id: \.self) { level in
                    let shadeColor = baseColor.level(level, for: .light)
                    let contrastColor = shadeColor.highestRatedContrastLevel
                    let contrastInfo = shadeColor.contrastInfo(with: contrastColor)
                    ShadeCell(level, shade: shadeColor, contrast: contrastColor, info: contrastInfo)
                }
            }
            VStack(spacing: 0) {
                ForEach(ColorLevel.allCases, id: \.self) { level in
                    let shadeColor = baseColor.level(level, for: .light)
                    let contrastColor = shadeColor.aaLargeContrastLevel
                    let contrastInfo = shadeColor.contrastInfo(with: contrastColor, for: .aaLarge)
                    ShadeCell(level, shade: shadeColor, contrast: contrastColor, info: contrastInfo)
                }
            }
        }
    }
}

/// Shows shades resolved against the current environment's colour scheme, with contrast info.
internal struct EnvironmentShadeView: View {

    @Environment(\.colorScheme)
    private var colorScheme

    private let baseColor = Color.pink

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                ForEach(ColorLevel.allCases, id: \.self) { level in
                    let shadeColor = baseColor.level(level, for: colorScheme)
                    let contrastColor = shadeColor.highestRatedContrastLevel
                    let contrastInfo = shadeColor.contrastInfo(with: contrastColor)
                    ShadeCell(level, shade: shadeColor, contrast: contrastColor, info: contrastInfo)
                }
            }
            VStack(spacing: 0) {
                ForEach(ColorLevel.allCases, id: \.self) { level in
                    let shadeColor = baseColor.level(level, for: colorScheme)
                    let contrastColor = shadeColor.aaLargeContrastLevel
                    let contrastInfo = shadeColor.contrastInfo(with: contrastColor, for: .aaLarge)
                    ShadeCell(level, shade: shadeColor, contrast: contrastColor, info: contrastInfo)
                }
            }
        }
    }
}

/// Demonstrates the simplified API — no `@Environment` needed at call sites.
internal struct AdaptiveShadeView: View {

    private let baseColor = Color.pink

    var body: some View {
        HStack {
            // Using level(_:) — adapts automatically to the environment
            VStack(spacing: 0) {
                ForEach(ColorLevel.allCases, id: \.self) { level in
                    Rectangle()
                        .fill(baseColor.level(level))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            // Using shorthand convenience properties — same behaviour
            VStack(spacing: 0) {
                Rectangle().fill(baseColor.level50).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level100).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level200).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level300).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level400).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level500).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level600).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level700).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level800).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level900).frame(maxWidth: .infinity, maxHeight: .infinity)
                Rectangle().fill(baseColor.level950).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview("ColorScheme: Fixed") { StandardShadeView() }
#Preview("ColorScheme: Environment") { EnvironmentShadeView() }
#Preview("ColorScheme: Adaptive") { AdaptiveShadeView() }

#endif
