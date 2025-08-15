//
//  FlitzWaveBroadcaster.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation
import CoreBluetooth

protocol WaveBroadcasterDelegate: AnyObject {
    func broadcasterDidRestoreState(_ broadcaster: WaveBroadcaster)
}

class WaveBroadcaster: NSObject {
    private var peripheralManager: CBPeripheralManager!
    private var service: CBMutableService?
    private var characteristic: CBMutableCharacteristic?
    
    var identity: String = ""
    
    weak var delegate: WaveBroadcasterDelegate?

    // HACK: peripheralManager:willRestoreState: 가 언제 호출될지 모르므로 delegate를 최대한 빠르게 설정함
    init(delegate: WaveBroadcasterDelegate? = nil) {
        super.init()
        // State restoration을 위한 identifier 설정
        let options: [String: Any] = [
            CBPeripheralManagerOptionRestoreIdentifierKey: "com.flitz.wave.broadcaster",
            CBPeripheralManagerOptionShowPowerAlertKey: true
        ]
        
        self.delegate = delegate
        
        self.peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil,
            options: options
        )
    }
    
    func start() {
        if identity.isEmpty {
            print("cannot start: identity is empty")
            return
        }
        
        // PeripheralManager가 준비될 때까지 대기
        guard peripheralManager.state == .poweredOn else {
            print("Bluetooth is not ready. Current state: \(peripheralManager.state.rawValue)")
            return
        }
        
        setupService()
    }
    
    private func setupService() {
        let serviceID = FlitzWaveServiceID.default.rawValue
        
        // 기존 서비스 정리
        self.peripheralManager.removeAllServices()
        self.peripheralManager.stopAdvertising()
        
        // 새 서비스 설정
        let service = CBMutableService(type: serviceID, primary: true)
        let characteristic = CBMutableCharacteristic(
            type: serviceID,
            properties: [.read],  // .notify가 있어야 하나?
            value: self.identity.data(using: .utf8),
            permissions: [.readable]
        )
        
        service.characteristics = [characteristic]
        self.service = service
        self.characteristic = characteristic
        
        self.peripheralManager.add(service)
    }
    
    func stop() {
        self.peripheralManager.removeAllServices()
        self.peripheralManager.stopAdvertising()
    }
    
}

// MARK: - CBPeripheralManagerDelegate
extension WaveBroadcaster: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Bluetooth is powered on")
            if !identity.isEmpty {
                setupService()
            }
        case .poweredOff:
            print("Bluetooth is powered off")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unsupported:
            print("Bluetooth is unsupported")
        case .unknown:
            print("Bluetooth state is unknown")
        @unknown default:
            print("Unknown bluetooth state")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("Failed to add service: \(error.localizedDescription)")
            return
        }
        
        print("Service added successfully")
        
        // 광고 시작 - 백그라운드 호환 설정
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [service.uuid],
            // CBAdvertisementDataLocalNameKey: nil
        ]
        
        peripheralManager.startAdvertising(advertisementData)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Failed to start advertising: \(error.localizedDescription)")
        } else {
            print("Started advertising successfully")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        // 읽기 요청 처리
        if request.characteristic.uuid == characteristic?.uuid {
            if let data = identity.data(using: .utf8) {
                request.value = data
                peripheral.respond(to: request, withResult: .success)
            } else {
                peripheral.respond(to: request, withResult: .invalidHandle)
            }
        } else {
            peripheral.respond(to: request, withResult: .attributeNotFound)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        // 앱이 종료됐다가 복원될 때 호출됨
        // NOTE: 저장된 상태를 사용해선 안됨: 매 실행마다 self.identity를 로테이션 해야 하기 때문에 부모로부터 새 identity를 받고, start()를 call하도록 재촉해야 함
        
        print("Restoring peripheral manager state")
        
        delegate?.broadcasterDidRestoreState(self)
    }
}

