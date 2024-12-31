//
//  DummyCard.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI

struct DummyCardView: View {
    @State
    var world: FZCardViewWorld = {
        let world = FZCardViewWorld()
        world.setup()
        
        return world
    }()
    
    var card: Binding<Flitz.Card?> = .constant(Flitz.Card())
    
    
    var body: some View {
        FZCardView(world: $world, enableGesture: true, gestureRecognizer: nil)
            .displayCard(card, to: $world)
    }
}

#Preview {
    VStack {
        DummyCardView()
    }
    .background(.blue)
}
