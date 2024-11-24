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
    var normalMapContent: any View
    
    var showNormalMap: Bool
    
    var scene: SCNScene = SCNScene()
    var cameraNode: SCNNode = SCNNode()
    
    var card: SCNNode!
    
    init(_ usdzName: String, _ cardContent: some View, _ normalMapContent: some View, showNormalMap: Bool = false) {
        self.usdzName = usdzName
        self.cardContent = cardContent
        self.normalMapContent = normalMapContent
        self.showNormalMap = showNormalMap
        
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
        
        let normalMapRenderer = ImageRenderer(content: AnyView(normalMapContent.blur(radius: 1)))
        normalMapRenderer.scale = 2.0
        guard let normalMapImage = normalMapRenderer.uiImage else {
            return
            // use the rendered image somehow
        }
        
        let colors: [UIColor] = [.red, .blue, .green, .yellow]
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0
        
        // card.childNodes[0].geometry!.subdivisionLevel = 1
        let material = card.childNodes[0].geometry!.materials.first!.copy() as! SCNMaterial
        // 이미지의 전체 ((0.0, 0.0) ~ (1.0, 1.0)) 를 텍스쳐로써 사용할 수 있도록 UV 맵을 다시 설정
        let scaleX = Float(uiImage.size.height) / Float(uiImage.size.width)
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(scaleX, 1, 1)
        
        material.diffuse.contents = showNormalMap ? normalMapImage : uiImage
        /*
        material.shaderModifiers = [
            .surface: """
            #pragma arguments
            float normalStrength;
            #pragma body
            _surface.diffuse = _surface.diffuse * normalStrength;
            """
        ]
         
         material.setValue(NSNumber(value: 2.0), forKey: "normalStrength")
         */
        
        
        // set normal map
        material.normal.contentsTransform = SCNMatrix4MakeScale(scaleX, 1, 1)
        material.normal.contents = normalMapImage
        material.lightingModel = .physicallyBased
        material.diffuse.magnificationFilter = .linear
        material.normal.magnificationFilter = .linear
        
        /*
        material.displacement.contentsTransform = SCNMatrix4MakeScale(scaleX, 1, 1)
        material.displacement.contents = normalMapImage
        material.displacement.intensity = 0.0075
         */
        
        
        card.childNodes[0].geometry!.replaceMaterial(at: 0, with: material)
        print("updated")
        SCNTransaction.commit()
        
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView(frame: .zero)
        sceneView.backgroundColor = .clear
        
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling2X
        // cameraNode.camera?.wantsHDR = true
        
        sceneView.scene = self.scene
        sceneView.pointOfView = self.cameraNode
        sceneView.isPlaying = true
        sceneView.rendersContinuously = true
        sceneView.contentScaleFactor = UIScreen.main.scale * 0.9
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        updateCardContent()
        uiView.scene = scene
    }
}


