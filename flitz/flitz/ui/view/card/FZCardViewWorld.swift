//
//  FZCardViewWorld.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Foundation
import SceneKit




/// FZCardViewWorld - FZCardView에서 렌더링을 위해 사용하는 Scene, Geometry Element 등을 관리하는 클래스.
class FZCardViewWorld {
    
    let scene: SCNScene = SCNScene()
    let mainCamera: SCNNode = SCNNode()
    let modelNode: SCNNode = SCNNode()
    
    private var cardIdCounter: Int = 0
    private(set) var cardArena: Set<FZCardViewCardInstance> = []
    
    init() {
        
    }
    
    private func setupScene() {
        // Clear the background color of the scene.
        scene.background.contents = UIColor.clear
        scene.rootNode.addChildNode(modelNode)
    }
    
    private func setupMainCamera() {
        mainCamera.camera = SCNCamera()
        mainCamera.position = SCNVector3(x: 0, y: 0, z: 10)
        
        scene.rootNode.addChildNode(mainCamera)
    }
    
    
    func setup() {
        setupScene()
        setupMainCamera()
    }
    
    func spawn(card: Flitz.Card) -> FZCardViewCardInstance {
        let id = cardIdCounter
        cardIdCounter += 1
        
        let instance = FZCardViewCardInstance(id: id, world: self, card: card)
        cardArena.insert(instance)
        
        instance.setup()
        instance.attachToScene()
        
        return instance
    }
    
    fileprivate func remove(card: FZCardViewCardInstance) {
        self.cardArena.remove(card)
    }
}


class FZCardViewCardInstance: Identifiable, Hashable {
    private static let MODEL_USDZ_NAME = "card_base_2_tmp"
    
    private static var baseModel: SCNReferenceNode? = loadBaseModel()
    
    private static func loadBaseModel() -> SCNReferenceNode? {
        guard let url = Bundle.main.url(forResource: MODEL_USDZ_NAME, withExtension: "usdz"),
              let referenceNode = SCNReferenceNode(url: url)
        else {
            return nil
        }
        
        referenceNode.load()
        
        if (!referenceNode.isLoaded) {
            // Sentry.captureMessage("Failed to load base model")
            return nil
        }
        
        return referenceNode
    }
    
    let id: Int
    
    let world: FZCardViewWorld
    let card: Flitz.Card
    
    let rootNode = SCNNode()
    var modelNode: SCNReferenceNode!
    
    private var mainTexture: UIImage? = nil
    private var normalMap: UIImage? = nil
    
    var showNormalMap: Bool = false {
        didSet {
            self.updateMaterial()
        }
    }
    
    var isAttachedToScene: Bool {
        return rootNode.parent != nil
    }
    
    init(id: Int, world: FZCardViewWorld, card: Flitz.Card) {
        self.id = id
        self.world = world
        self.card = card
    }
    
    deinit {
        self.destroy()
    }
    
    fileprivate func setup() {
        guard let baseModel = Self.loadBaseModel() else {
            // Sentry.captureMessage("Failed to load base model")
            return
        }
        
        modelNode = baseModel
        rootNode.addChildNode(self.modelNode)
        
        modelNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: deg2rad(-90))
        rootNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: deg2rad(90))
    }
    
    func destroy() {
        self.detachFromScene()
        
        modelNode.unload()
        rootNode.removeFromParentNode()
        
        world.remove(card: self)
    }
    
    @MainActor
    func updateContent() {
        let renderer = FZCardViewSwiftUICardRenderer()
        
        guard let mainTexture = try? renderer.render(card: card),
              let normalMap = try? renderer.renderNormalMap(card: card)
        else {
            print("Failed to render content")
            return
        }
        
        self.mainTexture = mainTexture
        self.normalMap = normalMap
        
        self.updateMaterial()
   }
    
    func updateMaterial() {
        guard let mainTexture = mainTexture,
              let normalMap = normalMap
        else {
            print("Failed to get texture")
            return
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0
        
        guard let cube = modelNode.childNode(withName: "Cube", recursively: true),
              let geometry = cube.childNodes.first?.geometry,
              let material = geometry.materials.first
        else {
            print("Failed to get material")
            return
        }
        
        let scaleX = Float(mainTexture.size.height) / Float(mainTexture.size.width)
        
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(scaleX, 1, 1)
        material.diffuse.contents = showNormalMap ? normalMap : mainTexture
        
        material.normal.contentsTransform = SCNMatrix4MakeScale(scaleX, 1, 1)
        material.normal.contents = normalMap
        
        material.lightingModel = .physicallyBased
        
        material.diffuse.magnificationFilter = .linear
        material.normal.magnificationFilter = .linear
        
        SCNTransaction.commit()
    }

    
    func attachToScene() {
        if isAttachedToScene {
            // WARN: 이미 Scene에 추가된 상태에서 다시 추가하려고 시도함
            return
        }
        
        world.modelNode.addChildNode(rootNode)
    }
    
    func detachFromScene() {
        rootNode.removeFromParentNode()
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FZCardViewCardInstance, rhs: FZCardViewCardInstance) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
