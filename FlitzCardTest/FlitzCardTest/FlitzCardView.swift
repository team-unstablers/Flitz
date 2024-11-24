//
//  FlitzCardView.swift
//  FlitzCardTest
//
//  Created by Gyuhwan Park on 11/20/24.
//

import SwiftUI
import SceneKit

func deg2rad(_ number: Float) -> Float {
    return number * .pi / 180
}

func rad2deg(_ number: Float) -> Float {
    return number * 180 / .pi
}


struct FlitzCardView: UIViewRepresentable {
    
    var usdzName: String
    var cardContent: any View
    
    var scene: SCNScene = SCNScene()
    var cameraNode: SCNNode = SCNNode()
    
    var card: SCNNode!
    
    init(_ usdzName: String, _ cardContent: some View) {
        self.usdzName = usdzName
        self.cardContent = cardContent
        
        self.setupScene()
        self.setupCamera()
        
        self.card = self.spawnCardModel()
    }
    
    private func setupScene() {
        scene.background.contents = UIColor.clear
    }
    
    private func setupCamera() {
        self.cameraNode.camera = SCNCamera()
        self.cameraNode.position = SCNVector3(x: 0, y: 0, z: 12.5)
        scene.rootNode.addChildNode(cameraNode)
        
        print(scene)
    }
        
    func spawnShape() {
        var geometry: SCNGeometry = SCNBox(width: 1.0,
                                          height: 1.0,
                                          length: 1.0,
                                   chamferRadius: 0.1)
        let geometryNode = SCNNode(geometry: geometry)
        
        geometry.materials.first?.diffuse.contents = UIColor.systemRed
        
        scene.rootNode.addChildNode(geometryNode)
    }
    
    func spawnCardModel() -> SCNNode {
        let url = Bundle.main.url(forResource: usdzName, withExtension: "usdz")!
        let referenceNode = SCNReferenceNode(url: url)!
        let wrapperNode = SCNNode()
        
        referenceNode.load()
        
        let card = referenceNode.childNode(withName: "Cube", recursively: true)!

        referenceNode.geometry?.materials[1].diffuse.contents = UIColor.red
        
        wrapperNode.addChildNode(referenceNode)
        
        // x: 90 degrees, y: 90 degrees
        referenceNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: deg2rad(-90))
        wrapperNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: deg2rad(90))
        
        scene.rootNode.addChildNode(wrapperNode)
        
        return card
    }
    
    func updateCardContent() {
        let renderer = ImageRenderer(content: AnyView(cardContent))
        renderer.scale = 2.0
        guard let uiImage = renderer.uiImage else {
            return
            // use the rendered image somehow
        }
        
        let colors: [UIColor] = [.red, .blue, .green, .yellow]
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0
        let material = card.childNodes[0].geometry!.materials.first!.copy() as! SCNMaterial
        material.diffuse.contents = uiImage
        card.childNodes[0].geometry!.replaceMaterial(at: 0, with: material)
        print("updated")
        SCNTransaction.commit()
        
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView(frame: .zero)
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling4X

        sceneView.scene = self.scene
        sceneView.pointOfView = self.cameraNode
        sceneView.isPlaying = true
        sceneView.rendersContinuously = true
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        updateCardContent()
        uiView.scene = scene
    }
}


