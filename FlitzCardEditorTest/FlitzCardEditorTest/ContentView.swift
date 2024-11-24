//
//  ContentView.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

struct ContentView: View {
    @State
    var isEditing: Bool = false {
        didSet {
            if !isEditing {
                cardInstance?.destroy()
                cardInstance = nil
                
                let card = Flitz.Card(background: backgroundImage != nil ? .uiImage(backgroundImage!) : nil,
                                      elements: elements)
                
                cardInstance = world.spawn(card: card)
                cardInstance?.updateContent()
            }
        }
    }
    
    @State
    var showNormalMap: Bool = false
    
    @State
    var backgroundImage: UIImage?
    
    @State
    var elements: [any Flitz.Element] = []
    
    @State
    var world: FZCardViewWorld = {
        let world = FZCardViewWorld()
        world.setup()
        
        return world
    }()
    
    @State
    var cardInstance: FZCardViewCardInstance? = nil
    
    var body: some View {
        if isEditing {
            VStack {
                CardEditor(backgroundImage: $backgroundImage, elements: $elements)
                    
                Button("Go To Preview") {
                    isEditing = false
                }
            }
        } else {
            VStack {
                FZCardView(world: $world)
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
                /*
                FlitzCardView("card_base_2_tmp",
                              CardCanvas(background: backgroundImage, elements: $elements),
                              CardCanvas(background: backgroundImage, elements: $elements, asNormalMap: true),
                              showNormalMap: showNormalMap
                )
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
                 */
                
                HStack {
                    Button("Toggle Normal Map") {
                        showNormalMap.toggle()
                        
                        cardInstance?.showNormalMap = showNormalMap
                    }
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
