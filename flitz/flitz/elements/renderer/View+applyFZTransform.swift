//
//  View+applyFZTransform.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//


import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func applyFZTransform(_ transform: Flitz.Transform, delta: Flitz.Transform = .zero, editable: Bool = false) -> some View {
        self.modifier(FZTransformModifier(transform: transform,
                                          delta: delta,
                                          editable: editable))
    }
}

struct FZTransformModifier: ViewModifier {
    @ObservedObject
    var transform: Flitz.Transform
    
    @ObservedObject
    var delta: Flitz.Transform
    
    var editable: Bool

    @GestureState
    private var gestureState: Bool = false
    
    @State
    private var viewportSize: CGSize = .zero
    
    @State
    private var elementSize: CGSize = .zero
    
    @State
    var isDragging: Bool = false {
        didSet { didGestureStateChanged() }
    }
    
    @State
    var isScaling: Bool = false {
        didSet { didGestureStateChanged() }
    }
    
    @State
    var isRotating: Bool = false {
        didSet { didGestureStateChanged() }
    }
    
    @State
    var backdropAllowsHitTesting: Bool = false
    
    @State
    var isAnimEnabled: Bool = false
    
    
    private func didGestureStateChanged() {
        let value = self.isDragging || self.isScaling || self.isRotating
        
        if (self.isAnimEnabled == value) {
            return
        }
        
        self.backdropAllowsHitTesting = value
        withAnimation() {
            self.isAnimEnabled = value
        }
    }
    
    
    @ViewBuilder
    func body(content: Content) -> some View {
        GeometryReader { geom in
            ZStack {
                if isAnimEnabled {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: geom.size.width, height: geom.size.height)
                        .allowsHitTesting(backdropAllowsHitTesting)
                }
                content
                    .overlay {
                        GeometryReader { elemGeom in
                            Rectangle()
                                .fill(.clear)
                                .allowsHitTesting(false)
                                .onAppear {
                                    self.elementSize = elemGeom.size
                                }
                        }
                    }
                    .overlay {
                        if self.gestureState {
                            Rectangle()
                                .fill(Color.black.opacity(0.5))
                        }
                    }
                    .rotationEffect(.degrees(transform.rotation))
                    .scaleEffect(transform.scale * delta.scale)
                    .position(x: transform.position.x * geom.size.width,
                              y: transform.position.y * geom.size.height)
                    .offset(x: delta.position.x * geom.size.width,
                            y: delta.position.y * geom.size.height)
            }
                .if(editable) {
                    $0
                        .gesture(FZDragGestureRecognizer { state, point in
                            if state == .changed {
                                isDragging = true
                                
                                delta.position = Flitz.Position(scaled: point, viewportSize: geom.size)
                            } else if state == .ended {
                                isDragging = false
                                
                                transform.position += Flitz.Position(scaled: point, viewportSize: geom.size)
                                delta.position = .zero
                            }
                        })
                        .gesture(FZMagnifyGestureRecognizer { state, scale in
                            print(scale)
                            if state == .changed {
                                isScaling = true
                                
                                delta.scale = scale
                            } else if state == .ended {
                                isScaling = false
                                
                                let tmpScale = transform.scale * scale
                                let scaledWidth = elementSize.width * tmpScale
                                let scaledHeight = elementSize.height * tmpScale
                                
                                /*
                                if scaledWidth < 128 || scaledHeight < 128 {
                                    delta.scale = 1.0
                                    return
                                }
                                 */
                                
                                transform.scale *= scale
                                delta.scale = 1.0
                            }
                        })
                        .gesture(FZRotationGestureRecognizer { state, scale in
                            transform.rotation = scale
                            
                            isRotating = state == .changed
                        })
                }
                .onAppear {
                    self.viewportSize = geom.size
                }
        }
    }
    
}

fileprivate extension Flitz.Position {
    init(scaled size: CGSize, viewportSize: CGSize) {
        self.init(x: size.width / viewportSize.width, y: size.height / viewportSize.height)
    }
    
    init(scaled size: CGPoint, viewportSize: CGSize) {
        self.init(x: size.x / viewportSize.width, y: size.y / viewportSize.height)
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
