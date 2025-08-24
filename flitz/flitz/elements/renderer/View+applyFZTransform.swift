//
//  View+applyFZTransform.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//


import Foundation

import CoreGraphics
import SwiftUI

extension View {
    @ViewBuilder
    func applyFZTransform(_ transform: Flitz.Transform, delta: Flitz.Transform = .zero, editable: Bool = false, eventHandler: @escaping (FZTransformEvent) -> Void) -> some View {
        self.modifier(FZTransformModifier(transform: transform,
                                          delta: delta,
                                          editable: editable,
                                          eventHandler: eventHandler))
    }
}

struct CardEditorDeleteElementButton: View {
    let willBeDeleted: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image("CardEditorCancelButtonIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
        }
        .padding(8)
        .background(.black.opacity(0.6))
        .cornerRadius(14)
        
        .overlay {
            if willBeDeleted {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.red.opacity(0.4))
            }
        }
    }
}

enum FZTransformEvent {
    case edit
    case delete
    case zIndexChange
}

struct FZTransformModifier: ViewModifier {
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @ObservedObject
    var transform: Flitz.Transform
    
    @ObservedObject
    var delta: Flitz.Transform
    
    var editable: Bool
    var eventHandler: ((FZTransformEvent) -> Void)? = nil

    @GestureState
    private var gestureState: Bool = false
    
    @State
    private var viewportSize: CGSize = .zero
    
    @State
    private var elementSize: CGSize = .zero
    
    @State
    var isDragging: Bool = false {
        didSet {
            didGestureStateChanged()
            
            if (isDragging && oldValue != isDragging) {
                eventHandler?(.zIndexChange)
            }
        }
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
    
    @State
    var willBeDeleted = false
    
    
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
                
                if isDragging {
                    CardEditorDeleteElementButton(willBeDeleted: willBeDeleted)
                        .position(x: geom.size.width / 2, y: geom.size.height - 64)
                }

                content
                    .opacity(willBeDeleted ? 0.75 : 1.0)
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
                        .gesture(FZDragGestureRecognizer { state, result in
                            let (point, rect) = result
                            
                            feedbackGenerator.prepare()
                            feedbackGenerator.impactOccurred()
                            
                            if state == .changed {
                                isDragging = true
                                
                                // print(geom.size)
                                // print(size)
                                
                                delta.position = Flitz.Position(scaled2: point, viewportSize: geom.size, actualSize: rect.size)
                                willBeDeleted = hitTestForDeleteButton(at: delta.position)
                                
                            } else if state == .ended {
                                isDragging = false
                                
                                transform.position += Flitz.Position(scaled2: point, viewportSize: geom.size, actualSize: rect.size)
                                delta.position = .zero
                                
                                if willBeDeleted {
                                    eventHandler?(.delete)
                                }
                            }
                        })
                        .gesture(FZMagnifyGestureRecognizer { state, scale in
                            // print(scale)
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
    
    /// FIXME: 이거 손가락의 위치를 기준으로 계산해야 하는데 지금은 element의 중심점 기준으로 계산하고 있음!!!
    func hitTestForDeleteButton(at position: Flitz.Position) -> Bool {
        // 아잇 염병할 좌표계 왜이래
        let actualPos = transform.position + position
        
        let x = actualPos.x * viewportSize.width
        let y = actualPos.y * viewportSize.height
        
        // print(x, y)
        
        let x1 = self.viewportSize.width / 2 - 32 // 28 + padding 4px
        let x2 = self.viewportSize.width / 2 + 32
        let y1 = self.viewportSize.height - 64 - 32
        let y2 = self.viewportSize.height - 64 + 32
        
        return x >= x1 && x <= x2 && y >= y1 && y <= y2
    }
    
}

fileprivate extension Flitz.Position {
    init(scaled size: CGSize, viewportSize: CGSize) {
        self.init(x: size.width / viewportSize.width, y: size.height / viewportSize.height)
    }
    
    init(scaled size: CGPoint, viewportSize: CGSize) {
        self.init(x: size.x / viewportSize.width, y: size.y / viewportSize.height)
    }
    
    /// 나는 수학 하면 안돼
    init(scaled2 point: CGPoint, viewportSize: CGSize, actualSize: CGSize) {
        let scaleX = viewportSize.width / actualSize.width
        let scaleY = viewportSize.height / actualSize.height
        
        // scaleX = 1.36... scaleY = 0.97254...
        // print(scaleX, scaleY)
        
        self.init(x: (point.x / viewportSize.width) * scaleX,
                  y: (point.y / viewportSize.height) * scaleX) // 아니 이게 왜 맞아? scaleY 쓰면 왜 맛이 가지??
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
