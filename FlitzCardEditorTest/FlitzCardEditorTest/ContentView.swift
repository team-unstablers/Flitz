//
//  ContentView.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

struct ContentView: View {
    @State
    var isEditing: Bool = false
    
    @State
    var showNormalMap: Bool = false
    
    @State
    var backgroundImage: UIImage?
    
    @State
    var elements: [any Flitz.Element] = []
    
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
                FlitzCardView("card_base_2_tmp",
                              CardCanvas(background: backgroundImage, elements: $elements),
                              CardCanvas(background: backgroundImage, elements: $elements, asNormalMap: true),
                              showNormalMap: showNormalMap
                )
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
                
                HStack {
                    Button("Toggle Normal Map") {
                        showNormalMap.toggle()
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
