//
//  FZCardView.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Foundation

import SceneKit
import SwiftUI

enum FZCardViewError: Error {
    case renderFailed
}

struct FZCardView: UIViewRepresentable, Equatable {
    
    @Binding
    var world: FZCardViewWorld
    
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView(frame: .zero)
        sceneView.backgroundColor = .clear
        
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling2X
        // cameraNode.camera?.wantsHDR = true
        
        sceneView.scene = world.scene
        sceneView.pointOfView = world.mainCamera
        sceneView.isPlaying = true
        sceneView.rendersContinuously = true
        sceneView.contentScaleFactor = UIScreen.main.scale * 0.9
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
                sceneView.addGestureRecognizer(panGesture)
        
        return sceneView
    }
    
    func updateUIView(_ sceneView: SCNView, context: Context) {
        print("updateUIView called")
        if (sceneView.scene !== world.scene) {
            sceneView.scene = world.scene
        }
        
        if (sceneView.pointOfView !== world.mainCamera) {
            sceneView.pointOfView = world.mainCamera
        }
    }
    
    static func == (lhs: FZCardView, rhs: FZCardView) -> Bool {
        lhs.world === rhs.world
    }
    
    // Coordinator 클래스 정의
    class Coordinator: NSObject {
        var world: FZCardViewWorld
        private var lastPanTranslation: CGPoint = .zero
        private var lastPanUpdateTime: Date = Date()
        private var velocity: CGFloat = 0
        private var displayLink: CADisplayLink?
        
        init(world: FZCardViewWorld) {
            self.world = world
        }
        
        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            let modelNode = world.modelNode
            let currentTime = Date()
            
            let translation = gesture.translation(in: gesture.view)
                    
            // 드래그 중 카메라 회전
            if gesture.state == .changed {
                let rotationSpeed: Float = 0.005 // 회전 속도 비율
                let deltaY = Float(translation.x - lastPanTranslation.x) * rotationSpeed
                modelNode.eulerAngles.y += deltaY
                velocity = translation.x - lastPanTranslation.x
                lastPanTranslation = translation
                lastPanUpdateTime = currentTime
            } else if gesture.state == .ended || gesture.state == .cancelled {
                let timeInterval = currentTime.timeIntervalSince(lastPanUpdateTime)
                lastPanTranslation = .zero
                // 제스처 종료 시 모멘텀 시작
                if timeInterval < 0.1 {
                    startMomentum(modelNode: modelNode)
                }
            }
        }
        private func startMomentum(modelNode: SCNNode) {
            // 기존 모멘텀 애니메이션 제거
            stopMomentum()

            // CADisplayLink 생성
            displayLink = CADisplayLink(target: self, selector: #selector(updateMomentum))
            displayLink?.add(to: .main, forMode: .default)
        }

        @objc private func updateMomentum() {
            let modelNode = world.modelNode

            // 모멘텀 감소율
            let friction: CGFloat = 0.95
            velocity *= friction
            
            // 속도가 거의 멈추면 애니메이션 종료
            if abs(velocity) < 0.1 {
                stopMomentum()
                return
            }
            
            // 속도 기반으로 Y축 회전 업데이트
            let deltaY = Float(velocity * 0.001) // 속도를 부드럽게 조정
            modelNode.eulerAngles.y += deltaY
        }

        private func stopMomentum() {
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    // makeCoordinator 메서드 구현
    func makeCoordinator() -> Coordinator {
        return Coordinator(world: world)
    }
}


#Preview {
    let world: FZCardViewWorld = {
        let world = FZCardViewWorld()
        world.setup()
        
        let card = Flitz.Card()
        let cardInstance = world.spawn(card: card)
        
        cardInstance.updateContent()
        
        return world
    }()
    
    VStack {
        FZCardView(world: .constant(world))
            .equatable()
    }
    .background(.black)
}
