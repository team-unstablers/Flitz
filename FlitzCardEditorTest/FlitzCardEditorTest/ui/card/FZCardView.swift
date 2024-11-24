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
        
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling2X
        // cameraNode.camera?.wantsHDR = true
        
        sceneView.scene = world.scene
        sceneView.pointOfView = world.mainCamera
        sceneView.isPlaying = true
        sceneView.rendersContinuously = true
        sceneView.contentScaleFactor = UIScreen.main.scale * 0.9
        
        return sceneView
    }
    
    func updateUIView(_ sceneView: SCNView, context: Context) {
        print("updateUIView called")
        sceneView.scene = world.scene
        sceneView.pointOfView = world.mainCamera
    }
    
    static func == (lhs: FZCardView, rhs: FZCardView) -> Bool {
        lhs.world === rhs.world
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
