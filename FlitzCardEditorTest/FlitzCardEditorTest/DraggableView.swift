//
//  Draggable.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

struct DraggableView<Content>: View where Content: View {
    @ObservedObject
    var transform: Flitz.Transform
    
    var content: () -> Content
    
    @State
    private var isDragging = false
    
    @State
    private var deltaPos = Flitz.Position.zero
    
    @State
    private var deltaScale = 1.0
    
    @State
    private var viewportSize = CGSize.zero
    
    var body: some View {
        GeometryReader { geom in
            ZStack {
                if isDragging {
                    Rectangle()
                        .fill(.blue)
                        .frame(width: geom.size.width, height: geom.size.height)
                }
                content()
                    .onAppear {
                        self.viewportSize = geom.size
                    }
                    .overlay {
                        if isDragging {
                            Rectangle()
                                .fill(Color.black.opacity(0.5))
                        }
                    }
                    .rotationEffect(.degrees(transform.rotation))
                    .scaleEffect(x: transform.scale * deltaScale, y: transform.scale * deltaScale)
                    .position(x: transform.position.x * geom.size.width,
                              y: transform.position.y * geom.size.height)
                    .offset(x: deltaPos.x * geom.size.width,
                            y: deltaPos.y * geom.size.height)
            }
            .gesture(
                SimultaneousGesture(drag, SimultaneousGesture(scale, rotation))
                    .onEnded { _ in
                        withAnimation {
                            self.isDragging = false
                        }
                    }
            )
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                withAnimation {
                    self.isDragging = true
                }
                
                let delta = Flitz.Position(scaled: gesture.translation, viewportSize: viewportSize)
                print(delta)
                deltaPos = delta
                // element.position = accumulatedOffset + gesture.translation
            }
        
            .onEnded { gesture in
                transform.position += Flitz.Position(scaled: gesture.translation, viewportSize: viewportSize)
                deltaPos = .zero
            }
    }
    
    var scale: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                withAnimation {
                    self.isDragging = true
                }
                
                deltaScale = scale
            }
            .onEnded { scale in
                transform.scale *= deltaScale
                deltaScale = 1.0
            }
    }
    
    var rotation: some Gesture {
        RotationGesture()
            .onChanged { rotation in
                withAnimation {
                    self.isDragging = true
                }
                
                transform.rotation = rotation.degrees
            }
    }
}

fileprivate extension Flitz.Position {
    init(scaled size: CGSize, viewportSize: CGSize) {
        self.init(x: size.width / viewportSize.width, y: size.height / viewportSize.height)
    }
    
    static func + (lhs: Flitz.Position, rhs: Flitz.Position) -> Flitz.Position {
        Flitz.Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: Flitz.Position, rhs: Flitz.Position) -> Flitz.Position {
        Flitz.Position(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func += (lhs: inout Flitz.Position, rhs: Flitz.Position) {
        lhs = lhs + rhs
    }
}

fileprivate extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }
}
