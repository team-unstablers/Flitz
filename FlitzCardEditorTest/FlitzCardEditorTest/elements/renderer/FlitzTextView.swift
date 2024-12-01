//
//  TExt.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension Flitz.Renderer {
    struct Text {
        struct TextRendererView: RendererView {
            @ObservedObject
            var element: Flitz.Text
            
            var body: some View {
                SwiftUI.Text(element.text)
                    .bold()
                    .padding(8)
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(.rect(cornerRadius: 8))
                    .padding(4)
            }
        }
        
        struct TextNormalMapRendererView: NormalMapRendererView {
            @ObservedObject
            var element: Flitz.Text
            
            var body: some View {
                SwiftUI.Text(element.text)
                    .bold()
                    .padding(7.5)
                    .background(Color.height4)
                    .foregroundStyle(Color.height8)
                    .clipShape(.rect(cornerRadius: 8))
                    .compositingGroup()
            }
        }
        
        struct TextEditorView: EditorView {
            @ObservedObject
            var element: Flitz.Text
            
            var body: some View {
                SwiftUI.TextField(text: $element.text) {}
                    .bold()
                    .padding()
                    .frame(maxWidth: 200)
                    .background(.white)
                    .foregroundStyle(.black)
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
    }
    
    typealias TextElementView = ElementView<Flitz.Text,
                                            Text.TextRendererView,
                                            Text.TextNormalMapRendererView,
                                            Text.TextEditorView>
}

