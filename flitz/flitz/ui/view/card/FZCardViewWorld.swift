//
//  FZCardViewWorld.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Foundation
import SceneKit
import QuartzCore




/// FZCardViewWorld - FZCardView에서 렌더링을 위해 사용하는 Scene, Geometry Element 등을 관리하는 클래스.
class FZCardViewWorld {
    
    let scene: SCNScene = SCNScene()
    let mainCamera: SCNNode = SCNNode()
    let modelNode: SCNNode = SCNNode()
    let mainLightNode: SCNNode = SCNNode()  // 주 광원 (Directional)
    let ambientLightNode: SCNNode = SCNNode()  // 환경광
    let fillLightNode: SCNNode = SCNNode()  // 보조 광원
    
    // private(set) var cardArena: Set<FZCardViewCardInstance> = []
    private(set) var cardArena: [String: FZCardViewCardInstance] = [:]
    private(set) var cardOrder: [String] = []
    
    var currentCard: FZCardViewCardInstance? {
        guard let firstId = cardOrder.first else { return nil }
        return cardArena[firstId]
    }
    
    init() {
        
    }
    
    deinit {
        // stopGlowAnimation()
    }
    
    private func setupScene() {
        // Clear the background color of the scene.
        scene.background.contents = UIColor.clear
        scene.rootNode.addChildNode(modelNode)
    }

    private func setupLight() {
        let supportsXDR = UIDevice.supportsXDR
        
        // 1. 주 광원 (Directional Light) - SceneKit 기본 라이팅의 핵심
        let mainLight = SCNLight()
        mainLight.type = .directional
        mainLight.intensity = supportsXDR ? 1000 : 800
        mainLight.temperature = 6500 // 주광색
        mainLight.castsShadow = true
        mainLight.shadowMode = .deferred
        mainLight.shadowSampleCount = 8
        mainLight.shadowRadius = 3
        mainLight.shadowColor = UIColor.black.withAlphaComponent(0.5)
        
        mainLightNode.light = mainLight
        mainLightNode.position = SCNVector3(x: 0, y: 30, z: 60)
        // 약간 아래를 향하도록 회전 (위에서 비스듬히 비추는 효과)
        mainLightNode.eulerAngles = SCNVector3(x: deg2rad(-45), y: 0, z: 0)
        
        // 2. 환경광 (Ambient Light) - 전체적인 기본 밝기
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = supportsXDR ? 300 : 200
        ambientLight.temperature = 6500
        
        ambientLightNode.light = ambientLight
        
        // 3. 보조 광원 (Fill Light) - 그림자를 부드럽게
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.intensity = supportsXDR ? 150 : 100
        fillLight.temperature = 5500 // 약간 따뜻한 색
        
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(x: -20, y: 10, z: 40)
        
        // Scene에 추가
        scene.rootNode.addChildNode(mainLightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(fillLightNode)
    }
    
    private func setupMainCamera() {
        let supportsXDR = UIDevice.supportsXDR
        
        mainCamera.camera = SCNCamera()
        mainCamera.position = SCNVector3(x: 0, y: 0, z: 15)
        mainCamera.camera?.focalLength = 35
        //mainCamera.camera?
        mainCamera.camera?.wantsHDR = supportsXDR
        mainCamera.camera?.wantsExposureAdaptation = supportsXDR
        
        scene.rootNode.addChildNode(mainCamera)
    }
    
    
    func setup() {
        setupScene()
        setupMainCamera()
        setupLight()
        // setupGlowEffect()
        
        // enableGlow(true)
    }

    // 광원 위치 업데이트 메서드 (자이로스코프 입력으로 주 광원 이동)
    func updateLightPosition(x: Float, y: Float, z: Float) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1 // 부드러운 전환
        
        // 주 광원 위치 업데이트 (directional light이므로 위치와 각도 모두 조정)
        mainLightNode.position = SCNVector3(x: x, y: 30 + y, z: 100)
        
        // 빛의 방향도 약간 조정 (기울기에 따라)
        mainLightNode.eulerAngles = SCNVector3(
            x: deg2rad(-45 + y * 0.5), 
            y: deg2rad(x * 0.5), 
            z: 0
        )
        
        // 보조 광원도 약간 이동 (반대 방향으로)
        fillLightNode.position = SCNVector3(x: -20 - x * 0.5, y: 10 - y * 0.3, z: 40)
        
        SCNTransaction.commit()
    }
    
    @available(*, deprecated, message: "use spawn(card:forId:) instead")
    func spawn(card: Flitz.Card) -> FZCardViewCardInstance {
        let uuid = UUID().uuidString
        
        return spawn(card: card, forId: uuid)
    }
    
    func spawn(card: Flitz.Card, forId id: String) -> FZCardViewCardInstance {
        let instance = FZCardViewCardInstance(id: id, world: self, card: card)
        cardArena[id] = instance
        
        instance.setup()
        instance.attachToScene()
        
        cardOrder.append(id)
        
        self.reorder()
        
        return instance
    }
    
    func reorder() {
        guard let cube = modelNode.childNode(withName: "Cube", recursively: true) else {
            print("cannot find Cube node in modelNode")
            return
        }
        
        // cube의 z축 길이를 구한다
        let zLength = cube.boundingBox.max.x - cube.boundingBox.min.x
        print(zLength)
        
        let yLength = cube.boundingBox.max.y - cube.boundingBox.min.y

        var zPosition: Float = -yLength
        
        for (index, id) in cardOrder.enumerated() {
            if index == 0 {
                if let card = cardArena[id] {
                    card.rootNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
                }
            } else {
                if let card = cardArena[id] {
                    let xOffset = Float.random(in: -0.15...0.15)
                    let yOffset = Float.random(in: -0.15...0.15)
                    
                    let deg = Float.random(in: 2.0...6.0) * (index % 2 == 0 ? -1 : 1)
                    // card.modelNode.eulerAngles.x = deg2rad(90.0 + deg)
                    
                    print(card.rootNode)
                    
                    let zOffset = -((Float(index) * zLength) + 0.05)
                    card.rootNode.position = SCNVector3(x: xOffset, y: yOffset, z: zPosition + zOffset)
                    
                    zPosition += zOffset
                }
            }
        }
    }
    
    func pop() {
        guard let firstId = cardOrder.first,
              let card = cardArena[firstId] else {
            print("No cards to pop")
            return
        }
        
        SCNTransaction.begin()
        card.rootNode.castsShadow = false
        SCNTransaction.commit()

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        
        card.rootNode.position.y = -10
        card.rootNode.opacity = 0
        
        self.cardOrder.remove(at: 0)
        self.reorder()
        
        SCNTransaction.completionBlock = {
            card.destroy()
            SCNTransaction.completionBlock = nil
            SCNTransaction.animationDuration = 0
        }
        
        SCNTransaction.commit()
    }

    fileprivate func remove(card: FZCardViewCardInstance) {
        self.cardArena.removeValue(forKey: card.id)
        self.cardOrder.removeAll { $0 == card.id }
    }
    
    
    fileprivate func remove(id: String) {
        self.cardArena.removeValue(forKey: id)
        self.cardOrder.removeAll { $0 == id }
    }
}


class FZCardViewCardInstance: Identifiable, Hashable {
    private static let MODEL_USDZ_NAME = "fzcard"
    
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
    
    let id: String
    
    let world: FZCardViewWorld
    let card: Flitz.Card
    
    var shouldDisplayBlurry: Bool = false
    
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
    
    init(id: String, world: FZCardViewWorld, card: Flitz.Card) {
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
        var options = FZCardViewCardRendererOptions()
        
        if self.shouldDisplayBlurry {
            options.insert(.renderBlurry)
        }
        
        guard let mainTexture = try? renderer.render(card: card, options: options),
              let normalMap = try? renderer.render(card: card, options: options.union(.renderNormalMap))
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
              let material = geometry.materials.first,
              let material2 = geometry.materials.last
        else {
            print("Failed to get material")
            return
        }
        
        let scaleX = Float(mainTexture.size.height) / Float(mainTexture.size.width)
        
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(scaleX, 1, 1)
        material.diffuse.contents = showNormalMap ? normalMap : mainTexture
        material.diffuse.intensity = 1.0
        
        material.normal.contentsTransform = SCNMatrix4MakeScale(scaleX, 1, 1)
        material.normal.contents = normalMap
        
        material.lightingModel = .physicallyBased
        
        // 반사율 및 금속성 조정
        material.metalness.contents = 0.2  // 약간의 금속성 (0.0-1.0)
        material.roughness.contents = 0.3  // 약간 매끄러운 표면 (0.0-1.0)
        
        // 광택 효과 강화
        material.specular.contents = UIColor.white
        material.specular.intensity = 0.8
        
        material.diffuse.magnificationFilter = .linear
        material.normal.magnificationFilter = .linear
        
        //
        material2.diffuse.contentsTransform = SCNMatrix4MakeScale(scaleX, 1, 1)
        material2.diffuse.contents = UIColor.white
        material2.diffuse.intensity = 1.0
        
        material2.lightingModel = .physicallyBased
        
        // 반사율 및 금속성 조정
        material2.metalness.contents = 0.2  // 약간의 금속성 (0.0-1.0)
        material2.roughness.contents = 0.3  // 약간 매끄러운 표면 (0.0-1.0)
        
        // 광택 효과 강화
        material2.specular.contents = UIColor.white
        material2.specular.intensity = 0.8
        
        material2.diffuse.magnificationFilter = .linear
        material2.normal.magnificationFilter = .linear
        
        
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
