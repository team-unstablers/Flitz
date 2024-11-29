//
//  FZCardView+displayCard.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Combine
import SwiftUI

extension FZCardView {
    func displayCard(_ card: Binding<Flitz.Card?>, to world: Binding<FZCardViewWorld>, showNormalMap: Binding<Bool> = .constant(false)) -> some View {
        self.modifier(FZCardViewDisplayCard(world: world,
                                            card: card,
                                            showNormalMap: showNormalMap))
    }
}

struct FZCardViewDisplayCard: ViewModifier, Equatable {
    
    @Binding
    var world: FZCardViewWorld
    
    @Binding
    var card: Flitz.Card?
    
    @Binding
    var showNormalMap: Bool
    
    @State
    var instance: FZCardViewCardInstance?
    
    func replaceCardInstance() {
        instance?.destroy()
        instance = nil
        
        if card == nil {
            return
        }
        
        instance = world.spawn(card: card!)
        instance?.updateContent()
    }
    
    func body(content: Content) -> some View {
        return content
            .onChange(of: card) {
                replaceCardInstance()
            }
            .onChange(of: showNormalMap) {
                instance?.showNormalMap = showNormalMap
            }
            .onAppear {
                replaceCardInstance()
            }
    }
    
    static func == (lhs: FZCardViewDisplayCard, rhs: FZCardViewDisplayCard) -> Bool {
        return lhs.world === rhs.world && lhs.card === rhs.card
    }
    
}
