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
    static let RESTORE_IDENTIFIER = "pl.unstabler.flitz.wave.discoverer"
    
    let locationReporter: WaveLocationReporter
    
    var centralManager: CBCentralManager!
    
    private var peripherals: Set<CBPeripheral> = []
    
    weak var delegate: WaveDiscovererDelegate?
    
    init(locationReporter: WaveLocationReporter) {
        self.locationReporter = locationReporter
        
        super.init()
        
        self.centralManager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: [
                CBCentralManagerOptionShowPowerAlertKey: true,
                CBCentralManagerOptionRestoreIdentifierKey: Self.RESTORE_IDENTIFIER
            ]
        )
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
        switch central.state {
        case .poweredOn:
            print("Bluetooth Central is powered on")
            // 백그라운드에서 복원될 때 스캔 재시작
            if central.isScanning {
                print("Already scanning")
            } else {
                print("Restarting scan")
                self.start()
            }
        case .poweredOff:
            print("Bluetooth Central is powered off")
        case .resetting:
            print("Bluetooth Central is resetting")
        case .unauthorized:
            print("Bluetooth Central is unauthorized")
        case .unsupported:
            print("Bluetooth Central is unsupported")
        case .unknown:
            print("Bluetooth Central state is unknown")
        @unknown default:
            print("Unknown bluetooth central state")
        }
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
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("restoring state")
        
        // restore scanning state
        if dict[CBCentralManagerRestoredStateScanServicesKey] is [CBUUID] {
            // restart scanning
            self.start()
        }
        
        guard let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] else {
            return
        }
        
        for peripheral in peripherals {
            self.peripherals.insert(peripheral)
            peripheral.delegate = self

            if peripheral.state == .connected {
                // already connected, discover services
                peripheral.discoverServices([FlitzWaveServiceID.default.rawValue])
            } else if peripheral.state == .disconnected {
                // not connected, connect
                central.connect(peripheral)
            }
        }
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


