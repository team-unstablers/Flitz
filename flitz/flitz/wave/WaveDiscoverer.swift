//
//  FlitzWaveDiscoverer.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import CoreBluetooth
import CoreLocation

protocol WaveDiscovererDelegate: AnyObject {
    func discoverer(_ discoverer: WaveDiscoverer, didDiscover sessionId: String, from location: CLLocation?)
}

class WaveDiscoverer: NSObject {
    let locationReporter: WaveLocationReporter
    let centralManager = CBCentralManager()
    
    private var peripherals: Set<CBPeripheral> = []
    
    weak var delegate: WaveDiscovererDelegate?
    
    init(locationReporter: WaveLocationReporter) {
        self.locationReporter = locationReporter
        super.init()
        
        centralManager.delegate = self
    }
    
    func start(for serviceIds: [FlitzWaveServiceID] = [.default]) {
        centralManager.scanForPeripherals(withServices: serviceIds.map { $0.rawValue },
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stop() {
        self.centralManager.stopScan()
    }
}


extension WaveDiscoverer: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // FIXME
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (self.peripherals.contains(peripheral)) {
            return
        }
        
        self.peripherals.insert(peripheral)
        central.connect(peripheral)
        print("connecting")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        peripheral.delegate = self
        peripheral.discoverServices([FlitzWaveServiceID.default.rawValue])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("disconencted")
        self.peripherals.remove(peripheral)
    }
}

extension WaveDiscoverer: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        print("service discovered")
        
        guard let service = peripheral.services?.first else {
            self.centralManager.cancelPeripheralConnection(peripheral)
            return
        }

        peripheral.discoverCharacteristics([FlitzWaveServiceID.default.rawValue], for: service)

        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristic = service.characteristics?.first else {
            self.centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        peripheral.readValue(for: characteristic)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        defer {
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
        
        guard let id = String(data: characteristic.value!, encoding: .utf8) else {
            return
        }
        
        print("discovered \(id)")
        self.delegate?.discoverer(self,
                                  didDiscover: id,
                                  from: locationReporter.location)
    }
}


