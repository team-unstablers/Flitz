//
//  View+aspectScale.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension View {
    func aspectScale(basedOn baseSize: CGSize, to size: CGSize) -> some View {
        let scale = baseSize.aspectScaled(toFit: size)
        
        return self.scaleEffect(x: scale, y: scale, anchor: .center)
    }
}
