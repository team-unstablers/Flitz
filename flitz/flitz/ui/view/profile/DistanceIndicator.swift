//
//  DistanceIndicator.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import SwiftUI

struct DistanceIndicatorPalette {
    let nearestBackground: Color
    let nearestForeground: Color
    let nearBackground: Color
    let nearForeground: Color
    let mediumBackground: Color
    let mediumForeground: Color
    let farBackground: Color
    let farForeground: Color
    let farthestBackground: Color
    let farthestForeground: Color
    let unknownBackground: Color
    let unknownForeground: Color
}

extension Color {
    struct DistanceIndicator {
        static let light = DistanceIndicatorPalette(nearestBackground: .init(r8: 169, g8: 222, b8: 165, a: 0.2),
                                                    nearestForeground: .init(hex: 0x387F37),
                                                    nearBackground: .init(r8: 205, g8: 235, b8: 159, a: 0.2),
                                                    nearForeground: .init(hex: 0x537F1C),
                                                    mediumBackground: .init(r8: 255, g8: 227, b8: 163, a: 0.2),
                                                    mediumForeground: .init(hex: 0x976A19),
                                                    farBackground: .init(r8: 255, g8: 210, b8: 168, a: 0.2),
                                                    farForeground: .init(hex: 0xB75612),
                                                    farthestBackground: .init(r8: 255, g8: 198, b8: 179, a: 0.24),
                                                    farthestForeground: .init(hex: 0xA75B43),
                                                    unknownBackground: .init(r8: 232, g8: 234, b8: 237, a: 0.6),
                                                    unknownForeground: .init(hex: 0x6B6F76))
        
        static let dark = DistanceIndicatorPalette(nearestBackground: .init(r8: 169, g8: 222, b8: 165, a: 0.2),
                                                   nearestForeground: .init(hex: 0x8BD88C),
                                                   nearBackground: .init(r8: 205, g8: 235, b8: 159, a: 0.2),
                                                   nearForeground: .init(hex: 0xDFF28A),
                                                   mediumBackground: .init(r8: 255, g8: 227, b8: 163, a: 0.2),
                                                   mediumForeground: .init(hex: 0xFFD080),
                                                   farBackground: .init(r8: 255, g8: 210, b8: 168, a: 0.2),
                                                   farForeground: .init(hex: 0xFFC199),
                                                   farthestBackground: .init(r8: 255, g8: 198, b8: 179, a: 0.24),
                                                   farthestForeground: .init(hex: 0xFFB8A8),
                                                   unknownBackground: .init(r8: 232, g8: 234, b8: 237, a: 0.6),
                                                   unknownForeground: .init(hex: 0x1F2428))
    }
}

struct DistanceIndicator: View {
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    var distance: FZUserFuzzyDistance
    
    var backgroundColor: Color {
        let palette = colorScheme == .light ?
            Color.DistanceIndicator.light :
            Color.DistanceIndicator.dark
        
        switch distance {
        case .nearest:
            return palette.nearestBackground
        case .near:
            return palette.nearBackground
        case .medium:
            return palette.mediumBackground
        case .far:
            return palette.farBackground
        case .farthest:
            return palette.farthestBackground
        default:
            return palette.unknownBackground
        }
    }
    
    var foregroundColor: Color {
        let palette = colorScheme == .light ?
            Color.DistanceIndicator.light :
            Color.DistanceIndicator.dark
        
        switch distance {
        case .nearest:
            return palette.nearestForeground
        case .near:
            return palette.nearForeground
        case .medium:
            return palette.mediumForeground
        case .far:
            return palette.farForeground
        case .farthest:
            return palette.farthestForeground
        default:
            return palette.unknownForeground
        }
    }
    
    var body: some View {
        VStack {
            Text(distance.asLocalizedString)
                .font(.fzSmall)
                .foregroundStyle(foregroundColor)
                .semibold()
        }
        .padding(.horizontal, 6)
        .frame(minWidth: 48, minHeight: 24)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    HStack {
        VStack {
            DistanceIndicator(distance: .nearest)
            DistanceIndicator(distance: .near)
            DistanceIndicator(distance: .medium)
            DistanceIndicator(distance: .far)
            DistanceIndicator(distance: .farthest)
            DistanceIndicator(distance: .init(rawValue: "알 수 없음"))
        }
        .colorScheme(.light)
        VStack {
            DistanceIndicator(distance: .nearest)
            DistanceIndicator(distance: .near)
            DistanceIndicator(distance: .medium)
            DistanceIndicator(distance: .far)
            DistanceIndicator(distance: .farthest)
            DistanceIndicator(distance: .init(rawValue: "알 수 없음"))
        }
        .colorScheme(.dark)
    }
}
