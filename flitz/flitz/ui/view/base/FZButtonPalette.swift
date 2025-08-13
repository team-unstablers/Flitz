//
//  FZButtonPalette.swift
//  Flitz
//
//  Created by Gyuhwan Park on 4/25/25.
//

import SwiftUI

struct FZButtonPalette: Hashable, Equatable {
    let lightBackground: Color
    let lightForeground: Color
    
    let darkBackground: Color
    let darkForeground: Color
    
    let disabledBackground: Color
    let disabledForeground: Color
}

extension FZButtonPalette {
    static let primary = FZButtonPalette(
        lightBackground: .mainBlack,
        lightForeground: .white,
        
        darkBackground: .white,
        darkForeground: .mainBlack,
        
        disabledBackground: .Grayscale.gray4,
        disabledForeground: .white
    )
    
    static let clear = FZButtonPalette(
        lightBackground: .clear,
        lightForeground: .mainBlack,
        
        darkBackground: .clear,
        darkForeground: .white,
        
        disabledBackground: .clear,
        disabledForeground: .Grayscale.gray4
    )
}
