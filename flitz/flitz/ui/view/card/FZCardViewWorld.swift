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
    let lightNode: SCNNode = SCNNode()
    
    private var cardIdCounter: Int = 0
    private(set) var cardArena: Set<FZCardViewCardInstance> = []
    
    // Glow effect properties
    private(set) var glowTechnique: SCNTechnique?
    private var displayLink: CADisplayLink?
    private var startTime: TimeInterval = 0
    private var glowEnabled: Bool = false
    
    // Glow parameters
    var glowColor: SCNVector3 = SCNVector3(1.0, 0.9, 0.8) {
        didSet {
            updateGlowParameters()
        }
    }
    var glowIntensity: Float = 0.35 {
        didSet {
            updateGlowParameters()
        }
    }
    var glowRadius: Float = 3.0 {
        didSet {
            updateGlowParameters()
        }
    }
    var glowThreshold: Float = 0.0 {
        didSet {
            updateGlowParameters()
        }
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
        let envLight = SCNLight()
        envLight.type = .ambient
        envLight.intensity = 800
        envLight.temperature = 6500 // 주광색
        
        scene.rootNode.light = envLight
        
        
        let light = SCNLight()
        light.type = .omni
        light.intensity = 600
        light.temperature = 6500 // 주광색
        
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 0, z: 40)
        
        scene.rootNode.addChildNode(lightNode)
    }
    
    private func setupMainCamera() {
        mainCamera.camera = SCNCamera()
        mainCamera.position = SCNVector3(x: 0, y: 0, z: 10)
        mainCamera.camera?.wantsHDR = true
        mainCamera.camera?.wantsExposureAdaptation = true
        
        scene.rootNode.addChildNode(mainCamera)
    }
    
    
    func setup() {
        setupScene()
        setupMainCamera()
        setupLight()
        // setupGlowEffect()
        
        // enableGlow(true)
    }

    // 광원 위치 업데이트 메서드
    func updateLightPosition(x: Float, y: Float, z: Float) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1 // 부드러운 전환
        
        lightNode.position = SCNVector3(x: x, y: y, z: z)
        
        SCNTransaction.commit()
    }
    
    // MARK: - Glow Effect Methods
    
    private func setupGlowEffect() {
        guard self.glowTechnique == nil else {
            print("Glow technique already set up")
            return
        }
        
        // Load the glow technique from plist
        guard let techniqueURL = Bundle.main.url(forResource: "CardGlowTechnique", withExtension: "plist"),
              let techniqueDictionary = NSDictionary(contentsOf: techniqueURL) as? [String: Any] else {
            print("Failed to load glow technique plist")
            return
        }
        
        // Create SCNTechnique with the dictionary
        glowTechnique = SCNTechnique(dictionary: techniqueDictionary)
        
        
        // Apply initial parameters
        updateGlowParameters()
    }
    
    func enableGlow(_ enabled: Bool) {
        glowEnabled = enabled
        
        if enabled {
            // Apply technique to camera
            // mainCamera.camera?.technique = glowTechnique
            startGlowAnimation()
        } else {
            // Remove technique
            mainCamera.camera?.technique = nil
            stopGlowAnimation()
        }
    }
    
    private func startGlowAnimation() {
        guard displayLink == nil else { return }
        
        startTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateGlowAnimation))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    private func stopGlowAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateGlowAnimation() {
        guard let technique = glowTechnique else { return }
        
        let currentTime = CACurrentMediaTime() - startTime
        glowTechnique?.setValue(Float(currentTime), forKey: "time")
        glowTechnique?.setValue(glowThreshold, forKey: "threshold")
        glowTechnique?.setValue(glowRadius, forKey: "radius")
        glowTechnique?.setValue(glowIntensity, forKey: "intensity")
        glowTechnique?.setValue(glowColor, forKey: "glowColor")

        
        print(Float(currentTime))
    }
    
    private func updateGlowParameters() {
        guard let technique = glowTechnique else { return }
        
        /*
        // Create a uniform struct matching GlowUniforms in the shader
        var uniforms: [String: Any] = [:]
        uniforms["threshold"] = glowThreshold
        uniforms["radius"] = glowRadius
        uniforms["glowColor"] = glowColor
        uniforms["intensity"] = glowIntensity
        uniforms["time"] = Float(0.0) // Will be updated by animation
         */
        
        // Set individual symbols
        glowTechnique?.setValue(glowThreshold, forKey: "threshold")
        glowTechnique?.setValue(glowRadius, forKey: "radius")
        glowTechnique?.setValue(glowIntensity, forKey: "intensity")
        glowTechnique?.setValue(glowColor, forKey: "glowColor")
    }
    
    func setGlowColor(r: Float, g: Float, b: Float) {
        glowColor = SCNVector3(r, g, b)
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
        material2.diffuse.intensity = 0.5
        
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
