//
//  FZCardView+displayCard.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Combine
import SwiftUI

extension FZCardView {
    @available(*, deprecated, message: "to disaplay card, use FZCardViewEx() instead")
    func displayCard(_ card: Binding<Flitz.Card?>, to world: Binding<FZCardViewWorld>, showNormalMap: Binding<Bool> = .constant(false)) -> some View {
        self
            .equatable()
            .modifier(FZCardViewDisplayCard(world: world,
                                            card: card,
                                            showNormalMap: showNormalMap))
    }
}

struct FZCardViewDisplayCard: ViewModifier {
    let lock = NSLock()
    
    @Environment(\.fzAssetsLoader)
    var assetsLoader: AssetsLoader
    
    @Binding
    var world: FZCardViewWorld
    
    @Binding
    var card: Flitz.Card?
    
    @Binding
    var showNormalMap: Bool
    
    @State
    var instance: FZCardViewCardInstance?
    
    func body(content: Content) -> some View {
        return content
            .onChange(of: instance) { prevValue, newValue in
                prevValue?.destroy()
                print("destroyed")
                newValue?.updateContent()
            }
            .onChange(of: card) {
                if let card = card {
                    instance = world.spawn(card: card)
                } else {
                    instance?.destroy()
                    instance = nil
                }
            }
            .onChange(of: showNormalMap) {
                instance?.showNormalMap = showNormalMap
            }
            .onChange(of: assetsLoader.images) {
                instance?.updateContent()
            }
            .onAppear {
                if let card = card {
                    instance = world.spawn(card: card)
                }
            }
            .onDisappear {
                instance?.destroy()
                instance = nil
            }
    }
}
