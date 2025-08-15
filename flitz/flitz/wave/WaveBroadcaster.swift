//
//  FlitzWaveBroadcaster.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation
import CoreBluetooth

class WaveBroadcaster {
    let peripheralManager: CBPeripheralManager = CBPeripheralManager()
    
    var identity: String = ""
    
    init() {
        
    }
    
    func start() {
        if (identity.isEmpty) {
            print("cannot start: identity is empty")
            return
        }
        
        let serviceID = FlitzWaveServiceID.default.rawValue
        
        let service = CBMutableService(type: serviceID, primary: true)
        let characteristic = CBMutableCharacteristic(
            type: serviceID,
            properties: [.read],
            value: self.identity.data(using: .utf8),
            permissions: [.readable]
        )
        
        service.characteristics = [characteristic]
        
        self.peripheralManager.removeAllServices()
        self.peripheralManager.stopAdvertising()
        
        self.peripheralManager.add(service)
        self.peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: nil,
            CBAdvertisementDataServiceUUIDsKey: [serviceID],
        ])
    }
    
    func stop() {
        self.peripheralManager.removeAllServices()
        self.peripheralManager.stopAdvertising()
    }
    
}
