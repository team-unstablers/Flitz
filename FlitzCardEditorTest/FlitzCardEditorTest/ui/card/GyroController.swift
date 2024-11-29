import CoreMotion
import SceneKit

class GyroController: NSObject {
    private let motionManager = CMMotionManager()
    var modelNode: SCNNode?
    var isTouching: Bool = false // 터치 상태 플래그
    private var previousYaw: Float? // 이전 프레임의 Yaw 값
    private var initialQuaternion: simd_quatf? // 초기 Quaternion 값

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
        guard let modelNode = modelNode else { return }

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

        // 이전 값과 비교하여 변화량 계산
        let deltaYaw = yaw - (previousYaw ?? yaw)

        // SceneKit의 eulerAngles.y에 누적 회전 적용
        previousYaw = yaw
        
        if !self.isTouching {
            modelNode.eulerAngles.y -= deltaYaw / 2
        }
    }

    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
