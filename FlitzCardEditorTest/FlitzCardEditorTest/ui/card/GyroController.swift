import CoreMotion
import SceneKit

class GyroController: NSObject {
    private let motionManager = CMMotionManager()
    var lightNode: SCNNode?
    private var previousYaw: Float? // 이전 프레임의 Yaw 값
    private var previousPitch: Float?
    private var initialQuaternion: simd_quatf? // 초기 Quaternion 값
    private var yAngle: Float = .zero
    private var xAngle: Float = .zero

    override init() {
        super.init()
        startDeviceMotionUpdates()
    }

    func startDeviceMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device Motion is not available.")
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60Hz 업데이트
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let motion = data, error == nil else { return }

            self.applyDeviceRotation(attitude: motion.attitude)
        }
    }

    func applyDeviceRotation(attitude: CMAttitude) {
        guard let lightNode = lightNode else { return }

        // CoreMotion의 Quaternion 가져오기
        let quaternion = simd_quatf(ix: Float(attitude.quaternion.x),
                                    iy: Float(attitude.quaternion.y),
                                    iz: Float(attitude.quaternion.z),
                                    r: Float(attitude.quaternion.w))

        // 초기 Quaternion 설정
        if initialQuaternion == nil {
            initialQuaternion = quaternion
        }

        // 초기값을 기준으로 보정된 Quaternion 계산
        let correctedQuaternion = quaternion * (initialQuaternion?.inverse ?? simd_quatf())

        // Quaternion에서 Yaw 값 추출
        let yaw = atan2(2.0 * (correctedQuaternion.imag.z * correctedQuaternion.real),
                        1.0 - 2.0 * (correctedQuaternion.imag.z * correctedQuaternion.imag.z))
        
        let sinPitch = 2.0 * (correctedQuaternion.real * correctedQuaternion.imag.x - correctedQuaternion.imag.y * correctedQuaternion.imag.z)
        let pitch = asin(max(-1.0, min(1.0, sinPitch)))
        

        // 이전 값과 비교하여 변화량 계산
        let deltaYaw = yaw - (previousYaw ?? yaw)
        let deltaPitch = pitch - (previousPitch ?? pitch)

        // SceneKit의 eulerAngles.y에 누적 회전 적용
        previousYaw = yaw
        previousPitch = pitch
        
        yAngle -= deltaYaw
        xAngle -= deltaPitch
        
        // when -pi/2 < yAngle < pi/2
        
        print("yAngle: \(yAngle), xAngle: \(xAngle)")
        if -0.4 < yAngle && yAngle < 0.4 {
            lightNode.eulerAngles.y = -yAngle * 2
        }
        
        if -0.8 < xAngle && xAngle < 0.3 {
            lightNode.eulerAngles.x = -xAngle * 2
        }
    }

    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
