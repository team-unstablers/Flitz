//
//  FlitzRendererBaseView.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension Flitz.Renderer {
    public protocol EditorView: View {
        associatedtype Element: Flitz.Element
        
        var element: Element { get }
        
        var submitHandler: () -> Void { get }
        
        init(element: Element, submitHandler: @escaping () -> Void)
    }
    
    public struct ElementEditorView<Element: Flitz.Element,
                                    Editor: EditorView>: View
    where Editor.Element == Element
    {
        @ObservedObject
        var element: Element
        
        var dismissHandler: () -> Void
        
        var body: some View {
            ZStack {
                GeometryReader { geom in
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .frame(width: geom.size.width, height: geom.size.height)
                        .onTapGesture {
                            dismissHandler()
                        }
                    Editor(element: element) {
                        dismissHandler()
                    }
                        .position(x: geom.size.width / 2,
                                  y: geom.size.height / 2)
                }

            }
            .zIndex(Double(element.zIndex))
        }
    }
}

