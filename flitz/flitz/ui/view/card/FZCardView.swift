//
//  FZCardView.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Foundation
import SceneKit
import SwiftUI
import CoreMotion

enum FZCardViewError: Error {
    case renderFailed
}

struct FZCardView: UIViewRepresentable, Equatable {
    
    @Binding
    var world: FZCardViewWorld
    
    var enableGesture: Bool = true
    
    @State
    var gestureRecognizer: UIGestureRecognizer!
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView(frame: .zero)
        sceneView.backgroundColor = .clear
        
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false // 자체 라이팅 사용하므로 비활성화
        sceneView.antialiasingMode = .multisampling2X
        // cameraNode.camera?.wantsHDR = true
        
        sceneView.scene = world.scene
        sceneView.pointOfView = world.mainCamera
        /*
        sceneView.isPlaying = true
        sceneView.rendersContinuously = true
         */
        sceneView.contentScaleFactor = UIScreen.main.scale * 0.9
        
        // 자이로스코프 업데이트 설정
        context.coordinator.setupMotionUpdates()
        
        return sceneView
    }
    
    func updateUIView(_ sceneView: SCNView, context: Context) {
        print("updateUIView called")
        
        sceneView.removeGestureRecognizer(context.coordinator.gestureRecognizer)
        
        print(enableGesture)
        if (enableGesture) {
            sceneView.addGestureRecognizer(context.coordinator.gestureRecognizer)
        }
        
        
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
        var gestureRecognizer: UIGestureRecognizer!
        
        private var lastPanTranslation: CGPoint = .zero
        private var lastPanUpdateTime: Date = Date()
        private var velocity: CGFloat = 0
        private var displayLink: CADisplayLink?
        
        // motionManager를 Coordinator로 이동
        private let motionManager = CMMotionManager()
        
        init(world: FZCardViewWorld) {
            self.world = world
            
            super.init()
            
            self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(Coordinator.handlePanGesture(_:)))
        }
        
        deinit {
            // 자이로스코프 및 기타 리소스 정리
            stopMomentum()
            motionManager.stopDeviceMotionUpdates()
        }
        
        // 자이로스코프 설정을 Coordinator로 이동
        func setupMotionUpdates() {
            guard motionManager.isDeviceMotionAvailable else { return }
            
            motionManager.deviceMotionUpdateInterval = 1.0 / 30.0 // 30Hz 업데이트
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let self = self, let motion = motion, error == nil else { return }
                
                // 자이로스코프 데이터를 사용하여 광원 위치 업데이트
                self.updateLightPosition(with: motion)
            }
        }
        
        private func updateLightPosition(with motion: CMDeviceMotion) {
            // 자이로스코프 데이터를 광원 위치로 변환
            // 기기의 기울기에 따라 -10~10 범위의 값으로 변환
            let maxOffset: Float = 10.0
            
            let xRoll = Float(motion.attitude.roll) * 2.0
            let yPitch = Float(motion.attitude.pitch) * 2.0
            
            // 기본 위치에서 기울기에 따라 ±maxOffset 이동
            let lightX = -xRoll * maxOffset
            let lightY = yPitch * maxOffset
            let lightZ: Float = 40.0 // 기본 Z 위치 유지
            
            world.updateLightPosition(x: lightX, y: lightY, z: lightZ)
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
