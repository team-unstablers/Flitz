//
//  TExt.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension Flitz.Renderer {
    struct TextRenderer: RendererView {
        @ObservedObject
        var element: Flitz.Text
        
        @State
        var isEditing = false
        
        private var bodyBase: some View {
            SwiftUI.Text(element.text)
                .bold()
        }
        
        var body: some View {
            if isEditing {
                SwiftUI.TextField(text: $element.text) {}
                    .bold()
                    .padding()
                    .frame(maxWidth: 200)
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(.rect(cornerRadius: 8))
                    .onSubmit {
                        isEditing = false
                    }
            } else {
                bodyBase
                    .padding(8)
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(.rect(cornerRadius: 8))
                    .padding(4)
                    .onTapGesture {
                        isEditing = true
                    }
            }
        }
        
        var normalMapBody: some View {
            bodyBase
                .padding(7.5)
                .background(Color.height4)
                .foregroundStyle(Color.height8)
                .clipShape(.rect(cornerRadius: 8))
                .compositingGroup()
        }
    }
}

