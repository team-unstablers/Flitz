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
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(element.text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }, id: \.self) { line in
                            SwiftUI.Text(line == "" ? "  " : line)
                                .multilineTextAlignment(.center)
                                .bold()
                                .foregroundStyle(.clear)
                                .background {
                                    GeometryReader { geom in
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.white)
                                            .frame(width: geom.size.width + 16, height: geom.size.height + 16)
                                            .position(x: geom.size.width / 2, y: geom.size.height / 2)
                                    }
                                }
                        }
                    }
                    VStack(spacing: 0) {
                        ForEach(element.text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }, id: \.self) { line in
                            SwiftUI.Text(line == "" ? "  " : line)
                                .multilineTextAlignment(.center)
                                .bold()
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
        }
        
        struct TextNormalMapRendererView: NormalMapRendererView {
            @ObservedObject
            var element: Flitz.Text
            
            var body: some View {
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(element.text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }, id: \.self) { line in
                            SwiftUI.Text(line == "" ? "  " : line)
                                .multilineTextAlignment(.center)
                                .bold()
                                .foregroundStyle(.clear)
                                .background {
                                    GeometryReader { geom in
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.init(r8: 192, g8: 192, b8: 255, a: 1.0))
                                            .frame(width: geom.size.width + 15.5, height: geom.size.height + 15.5)
                                            .position(x: geom.size.width / 2, y: geom.size.height / 2)
                                    }
                                }
                        }
                    }
                    .compositingGroup()
                    .shadow(color: Color(r8: 0, g8: 192, b8: 255, a: 1.0), radius: 0.75, x: -0.5, y: -0.5)
                    .shadow(color: Color(r8: 192, g8: 0, b8: 255, a: 1.0), radius: 0.75, x:  0.5, y:  0.5)
                    .blur(radius: 1.0)

                    VStack(spacing: 0) {
                        ForEach(element.text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }, id: \.self) { line in
                            SwiftUI.Text(line == "" ? "  " : line)
                                .multilineTextAlignment(.center)
                                .bold()
                                .foregroundStyle(Color(r8: 224, g8: 224, b8: 255, a: 1.0))
                                .shadow(color: Color(r8: 0, g8: 224, b8: 255, a: 1.0), radius: 0.75, x: -0.25, y: -0.25)
                                .shadow(color: Color(r8: 224, g8: 0, b8: 255, a: 1.0), radius: 0.75, x:  0.25, y:  0.25)
                                .compositingGroup()
                                .blur(radius: 0.5)
                        }
                    }
                }
                .compositingGroup()
            }
        }
        
        struct TextEditorView: EditorView {
            @ObservedObject
            var element: Flitz.Text
            
            var submitHandler: () -> Void
            
            @State
            var text: String = ""
            
            @State
            var splitText: [String] = []
            
            @FocusState
            var isFocused: Bool
            
            init(element: Flitz.Text, submitHandler: @escaping () -> Void) {
                self.element = element
                self.submitHandler = submitHandler
            }
            
            var body: some View {
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(0..<splitText.count, id: \.self) { line in
                            SwiftUI.Text(splitText[line] == "" ? "  " : splitText[line])
                                .fixedSize(horizontal: true, vertical: false)
                                .multilineTextAlignment(.center)
                                .bold()
                                .foregroundStyle(.clear)
                                .background {
                                    GeometryReader { geom in
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.white)
                                            .frame(width: geom.size.width + 16, height: geom.size.height + 16)
                                            .position(x: geom.size.width / 2, y: geom.size.height / 2)
                                    }
                                }
                        }
                    }
                    VStack(spacing: 0) {
                        ForEach(0..<splitText.count, id: \.self) { line in
                            SwiftUI.Text(splitText[line] == "" ? "  " : splitText[line])
                                .multilineTextAlignment(.center)
                                .bold()
                                .foregroundStyle(.black)
                        }
                    }
                    
                    SwiftUI.TextField(text: $text, axis: .vertical) {}
                        .focused($isFocused)
                        .multilineTextAlignment(.center)
                        .bold()
                        .padding(0)
                        .background(.clear)
                        .foregroundStyle(.clear)
                        .clipShape(.rect(cornerRadius: 8))
                        .onSubmit {
                            submitHandler()
                        }
                }
                .onAppear {
                    self.text = element.text
                    self.isFocused = true
                }
                .onChange(of: text) {
                    splitText = text
                        .split(separator: "\n", omittingEmptySubsequences: false)
                        .map { String($0) }
                    element.text = text
                }
            }
        }
    }
    
    typealias TextElementView = ElementView<Flitz.Text,
                                            Text.TextRendererView,
                                            Text.TextNormalMapRendererView>
    
    typealias TextElementEditorView = ElementEditorView<Flitz.Text,
                                                        Text.TextEditorView>
    
}

#Preview {
    @State
    @Previewable
    var text: String = "asdf"
    
    var element: Flitz.Text = Flitz.Text("Hello, World!\n\n\n나는 여기에 살아있다")
    
    
    VStack {
        Flitz.Renderer.Text.TextEditorView(element: element) {
            
        }
        
        TextField(text: $text, axis: .vertical) {
            Text("Type here")
        }
        
        .background(.white)
        .foregroundStyle(.black)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}
