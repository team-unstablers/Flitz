//
//  SimplecardPreview.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct WaveCardPreviewEx: View {
    @Binding
    var cardMeta: FZCard?
    
    @State
    var card: Flitz.Card? = nil

    @State
    var world: FZCardViewWorld = {
        let world = FZCardViewWorld()
        world.setup()
        
        return world
    }()
    
    var body: some View {
        FZCardView(world: world, enableGesture: true)
            .displayCard($card, to: $world, showNormalMap: .constant(false))
            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
            .onAppear {
                self.card = cardMeta?.content
            }
    }
}
